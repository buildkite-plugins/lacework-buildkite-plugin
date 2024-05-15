#!/bin/bash

set -euo pipefail

function configure_plugin() {

    # required options
    export ACCOUNT_NAME="${BUILDKITE_PLUGIN_LACEWORK_ACCOUNT_NAME:-}"

    export SCAN_TYPE="${BUILDKITE_PLUGIN_LACEWORK_SCAN_TYPE:-}"

    #validate required options
    if [ -z "${ACCOUNT_NAME}" ]; then
        echo "ERROR: Missing required config 'account-name'" >&2
        annotate_build_no_token
        exit 1
    fi

    if [ -z "${SCAN_TYPE}" ]; then
        echo "ERROR: Missing required config 'scan-type'" >&2
        exit 1
    fi

    #other options
    
    export API_KEY_ENV_VAR="${BUILDKITE_PLUGIN_LACEWORK_API_KEY_ENV_VAR:-}"

    export API_KEY_SECRET_ENV_VAR="${BUILDKITE_PLUGIN_LACEWORK_API_KEY_SECRET_ENV_VAR:-}"

    #if LW_API_KEY is defined locally, use that if the buildkite environment variable is absent
    if [ -z "${API_KEY_ENV_VAR}"  ]; then
         export API_KEY_ENV_VAR="${LW_API_KEY:-}" 
    fi
    #if LW_API_SECRET is defined locally, use that if the buildkite environment variable is absent
    if [ -z "${API_KEY_SECRET_ENV_VAR}"  ]; then
         export API_KEY_SECRET_ENV_VAR="${LW_API_SECRET:-}" 
    fi

    export PROFILE="${BUILDKITE_PLUGIN_LACEWORK_PROFILE:-}" 

    if [ -z "${API_KEY_ENV_VAR}" ] || [ -z "${API_KEY_SECRET_ENV_VAR}" ]; then
        if [ -z "${PROFILE}" ] && [ "${SCAN_TYPE}" != "vulnerability" ]; then
            echo "ERROR: Missing Lacework API Key and Secret or profile" >&2
            annotate_build_no_token
            exit 1
        fi
    fi

    

    # need to export the below ENV variables for IAC to work since you can't pass those via CLI
    if [ "${SCAN_TYPE}" == "iac" ]; then
        export IAC_SCAN_TYPE="${BUILDKITE_PLUGIN_LACEWORK_IAC_SCAN_TYPE:-}"
        export LW_ACCOUNT="${ACCOUNT_NAME}"
        export LW_API_KEY="${API_KEY_ENV_VAR}"
        export LW_API_SECRET="${API_KEY_SECRET_ENV_VAR}"

        if [ -z "${IAC_SCAN_TYPE}" ] || [ -z "${LW_ACCOUNT}" ] ||  [ -z "${LW_API_KEY}" ] ||  [ -z "${LW_API_SECRET}" ]; then
            if [ -z "${PROFILE}" ]; then
                echo "ERROR: Missing config related to IAC scans. Need the following: IAC_SCAN_TYPE, LW_ACCOUNT, LW_API_KEY, LW_API_SECRET" >&2
                exit 1
            fi
        fi
    fi

    #vuln scan related env variables
    if [ "${SCAN_TYPE}" == "vulnerability" ]; then
        export ACCESS_TOKEN_ENV_VAR="${BUILDKITE_PLUGIN_LACEWORK_ACCESS_TOKEN_ENV_VAR:-}"
        export VULNERABILITY_SCAN_REPOSITORY="${BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_REPOSITORY:-}"
        export VULNERABILITY_SCAN_TAG="${BUILDKITE_PLUGIN_LACEWORK_VULNERABILITY_SCAN_TAG:-}"
        if [ -z "${ACCESS_TOKEN_ENV_VAR}" ] || [ -z "${VULNERABILITY_SCAN_REPOSITORY}" ] || [ -z "${VULNERABILITY_SCAN_TAG}" ]; then
            echo "ERROR: Missing config related to vulnerability scans. Need the following: ACCESS_TOKEN_ENV_VAR, VULNERABILITY_SCAN_REPOSITORY, VULNERABILITY_SCAN_TAG" >&2
            exit 1
        fi
    fi

    export FAIL_LEVEL="${BUILDKITE_PLUGIN_LACEWORK_FAIL_LEVEL:-}"

}

# Lacework Scans based on the provided scan tool
function lacework_scan() {
    case "${SCAN_TYPE}" in
        sca)
        lacework_sca
        ;;

        iac)
        lacework_iac
        ;;

        vulnerability)
        lacework_vulnerability
        ;;

        sast)
        lacework_sast
        ;;
    esac
}


function lacework_sca() {

    echo "--- Running Lacework SCA scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
        CMD+=(
            --profile "$PROFILE"
        )
    else
        CMD+=(
        --account "${ACCOUNT_NAME}"
        --api_key "${API_KEY_ENV_VAR}"
        --api_secret "${API_KEY_SECRET_ENV_VAR}"
    )
    fi  

    CMD+=(
        sca scan .
        --save-results
    )
        

    echo "${CMD[@]}"

    "${CMD[@]}" 
}

function lacework_sast() {

    echo "--- Running Lacework SAST scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
        CMD+=(
            --profile "$PROFILE"
        )
    else
        CMD+=(
        --account "${ACCOUNT_NAME}"
        --api_key "${API_KEY_ENV_VAR}"
        --api_secret "${API_KEY_SECRET_ENV_VAR}"
        )
    fi  

    

    SARIF_ARTIFACT="lacework-sast-report-${BUILDKITE_PIPELINE_SLUG}-${BUILDKITE_BUILD_NUMBER}.sarif"

    CMD+=(
        sast scan -o "${SARIF_ARTIFACT}"
    )
        

    echo "${CMD[@]}"

    "${CMD[@]}" 

    annotate_and_upload_build_sast "${SARIF_ARTIFACT}"
}

function lacework_iac() {

    echo "--- Running Lacework IAC scan"

    CMD=(
    lacework
    )


    CMD+=(
        iac
        "${IAC_SCAN_TYPE}"
    )

    if [ -n "$PROFILE" ]; then
    CMD+=(
        --iac-profile "$PROFILE"
    )
    fi  

    if [ -n "$FAIL_LEVEL" ]; then
    CMD+=(
        --fail "$FAIL_LEVEL"
    )
    fi  


    echo "${CMD[@]}"

    "${CMD[@]}" 
}

function lacework_vulnerability() {

    echo "--- Running Lacework Container Vulnerability scan"

    CMD=(
    lacework
    )

    if [ -n "$PROFILE" ]; then
        CMD+=(
            --profile "$PROFILE"
        )
    else
        CMD+=(
            --account-name "${ACCOUNT_NAME}"
        )
    fi  

    #access token can't be passed via profile so we still need to pass it below
    CMD+=(
        --access-token "${ACCESS_TOKEN_ENV_VAR}"
    )

    CMD+=(
        vuln-scanner -s image evaluate
        "${VULNERABILITY_SCAN_REPOSITORY}"  
        "${VULNERABILITY_SCAN_TAG}"
    )

    if [ -n "$FAIL_LEVEL" ]; then
    CMD+=(
        "--policy --$FAIL_LEVEL-violation-exit-code 1"
    )
    fi  

    
    echo "${CMD[@]}"

    "${CMD[@]}"
}


# format the output into an annotation with a link to the LW trial if credentials are missing
function annotate_build_no_token() {

    style="error"
    
    annotation=$(cat << EOF
   <h3>Lacework scan</h3>
   <p>Lacework needs an account, tenant or token. If you need to start a trial click on the link below. </p>
    <a href=https://aws.amazon.com/marketplace/pp/prodview-wcor2dssgwok6>Start a Lacework trial</a>
EOF
)
   
    buildkite-agent annotate "${annotation}" --style "${style}" --context "lacework"
}

function annotate_and_upload_build_sast() {

    sarif_artifact=$1

    buildkite-agent artifact upload "${sarif_artifact}"

    style="success"
    message="<p>Lacework code scan completed and uploaded the results as a SARIF build artifact.</p>"

    annotation=$(cat << EOF
   <h3>Lacework SAST Scan</h3>
   ${message}
    <a href=artifact://${sarif_artifact}>View Complete Scan Result</a>
EOF
)
   
    buildkite-agent annotate "${annotation}" --style "${style}" --context "lacework-sast"
}
