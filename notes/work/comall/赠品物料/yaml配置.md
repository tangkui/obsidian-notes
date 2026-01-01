## dc-package-refund
``` yaml
# 移库退货物料消息-生产者  
B2B_REFUND_MATERIAL_OUTPUT:  
  contentType: application/json  
  destination: B2B_REFUND_MATERIAL_OUTPUT
```
## dc-b2b-order
```yaml
#b2b移库退货物料信息  
B2B_REFUND_MATERIAL_INPUT:  
  contentType: application/json  
  group: B2B_REFUND_MATERIAL_INPUT  
  destination: B2B_REFUND_MATERIAL_OUTPUT
```