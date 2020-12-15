# create new policy definition
az policy definition create \
  --name tagging-policy \
  --description "This policy denies deployment of new Resource unless at least one tag is created." \
  --display-name "Deny creation of Resources with no tags" \
  --mode "Indexed" \
  --rules tagging-policy-rule.json \
  --subscription "$ARM_SUBSCRIPTION_ID"

# create policy definition assignment
az policy assignment create \
  --name tagging-policy-assignment \
  --policy tagging-policy \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID" \
  --display-name "Assignment of tagging-policy to all Resources in the subscription." \
  --sku "free"