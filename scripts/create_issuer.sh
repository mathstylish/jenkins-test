#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BKO_ISSUER_CONFIG_DIR="$PROJECT_ROOT/cloudformation/backoffice-issuer-config"
MAIN_YML_FILE="$BKO_ISSUER_CONFIG_DIR/main.yml"
ISSUER_INPUT="$1"

if [[ -z "$ISSUER_INPUT" ]]; then
  echo "Usage: $0 \"Issuer Name\" (ex: \"Alpha Global\")"
  exit 1
fi

ISSUER_NAME_SPACED="$(echo "$ISSUER_INPUT" | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')"
ISSUER_NAME_PASCAL="$(echo "$ISSUER_NAME_SPACED" | sed 's/ //g')"
ISSUER_NAME_LOWER="$(echo "$ISSUER_NAME_SPACED" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"

TEMPLATE_FILE="$BKO_ISSUER_CONFIG_DIR/default-backoffice-template.yml"
DEST_FILE="$BKO_ISSUER_CONFIG_DIR/${ISSUER_NAME_LOWER}-backoffice-template.yml"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: Template $TEMPLATE_FILE not found"
  exit 1
fi

sed \
  -e "s/Issuer Name/${ISSUER_NAME_SPACED}/g" \
  -e "s/IssuerName/${ISSUER_NAME_PASCAL}/g" \
  -e "s/issuername/${ISSUER_NAME_LOWER}/g" \
  "$TEMPLATE_FILE" > "$DEST_FILE"

echo "Generated template: $DEST_FILE"

STACK_BLOCK="
  Backoffice${ISSUER_NAME_PASCAL}BankStack:
    Type: AWS::CloudFormation::Stack
    Condition: DevOrProd
    Properties:
      Tags:
        - Key: system
          Value: backoffice
        - Key: module
          Value: backoffice
        - Key: pci
          Value: na
      TemplateURL: \"${ISSUER_NAME_LOWER}-backoffice-template.yml\"
      Parameters:
        envName: !Ref envName
        AuthName: backoffice-${ISSUER_NAME_LOWER}
        issuer: ${ISSUER_NAME_LOWER}
"

if grep -q "Backoffice${ISSUER_NAME_PASCAL}BankStack:" "$MAIN_YML_FILE"; then
  echo "Backoffice${ISSUER_NAME_PASCAL}BankStack block already exists in main.yml. Nothing was changed."
else
  echo "$STACK_BLOCK" >> "$MAIN_YML_FILE"
  echo "Stack added in $MAIN_YML_FILE"
fi
