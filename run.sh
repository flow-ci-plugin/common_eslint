# ************************************************************
#
# This step will use Nodejs anlayzer Eslint to check files
#
#   Variables used:
#
#   Outputs:
#     $FLOW_ESLINT_WARNING_COUNT
#     $FLOW_ESLINT_ERROR_COUNT
#     $FLOW_ESLINT_FILE_COUNT
#     $FLOW_ESLINT_LOG_PATH
#
# ************************************************************

set +e
cd $FLOW_CURRENT_PROJECT_PATH
source $HOME/.nvm/nvm.sh
source $HOME/.rvm/scripts/rvm
nvm use $FLOW_NODE_VERSION
npm -v
node -v
LOCAL_ESLINT_PATH=./node_modules/.bin/eslint
if [[ ! -f $LOCAL_ESLINT_PATH ]]; then
  npm install eslint
fi

ESLINT=$(find . -maxdepth 1 -name .eslintrc* -print -quit 2>&1)
if [[ -z $ESLINT ]]; then
  curl -sSL https://raw.githubusercontent.com/FIRHQ/code-quality-configs/master/eslintrc.yml > .eslintrc.yml
fi

ESLINTIGNORE=$(find . -maxdepth 1 -name .eslintignore -print -quit 2>&1)
if [[ -z $ESLINTIGNORE ]]; then
  echo '
**/ignored.js
  ' > .eslintignore
fi

$LOCAL_ESLINT_PATH . -f json -o ${FLOW_WORKSPACE}/output/eslint.json | $LOCAL_ESLINT_PATH . --quiet

FLOW_ESLINT_LOG_PATH=${FLOW_WORKSPACE}/output/eslint.json
FLOW_ESLINT_WARNING_COUNT=$(jq '[.[] | .warningCount ] | reduce .[] as $item (0; . + $item) ' $FLOW_ESLINT_LOG_PATH)
FLOW_ESLINT_ERROR_COUNT=$(jq '[.[] | .errorCount ] | reduce .[] as $item (0; . + $item) ' $FLOW_ESLINT_LOG_PATH)
FLOW_ESLINT_FILE_COUNT=$(jq '[.[] | .errorCount ] | length' $FLOW_ESLINT_LOG_PATH)
