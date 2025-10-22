# SIT测试-自测

## MQ
https://puat-aly-rbtmq-g5.chowtaifook.sz/#/queues/%2F/ORDER_COMMAND_INPUT.ORDER_COMMAND_INPUT_GROUP

## 队列
ORDER_COMMAND_INPUT.ORDER_COMMAND_INPUT_GROUP

## Headers
destination：OrderSyncRequest
## virtual host
/

## 数据清除

> 替换条件值
``` sql
delete from ctf_order.dc_order where outer_order_id = '4821277033519777730';  
delete from ctf_order.dc_order_item where order_id = '10006058404821277033519777730';  
delete from ctf_order.dc_order_item_expand where order_id = '10006058404821277033519777730';  
delete from ctf_order.dc_order_exception where order_id = '10006058404821277033519777730';  
delete from ctf_order.dc_order_index where outer_order_id = '4821277033519777730';  
delete from ctf_order.dc_order_invoice where outer_order_id = '4821277033519777730';  
delete FROM ctf_promotion.dc_promotion_order_rule_detail_record  WHERE order_code ='4821277033519777730';
```

## 关键数据查询
``` sql
select * from ctf_order.dc_order where outer_order_id = '4821277033519777730';  
select * from ctf_order.dc_order_item where order_id = '10006058404821277033519777730';  
select * from ctf_order.dc_order_invoice where order_id = '10006058404821277033519777730';  
select * from ctf_order.dc_order_item_expand where order_id = '10006058404821277033519777730';  
select  * from ctf_order.dc_order_exception where order_id = '10006058404821277033519777730';
```

## 磐石赠品
``` json
{
  "approveInvoiceFlag": false,
  "buyerMessage": "测试sit",
  "buyerNick": "我**",
  "buyerPaidAmount": 100.00,
  "buyerRemarks": "测试sit",
  "channelId": 1000,
  "discountAmount": 0.00,
  "freightFee": 0.00,
  "freightInsuranceFee": 0,
  "goodsAmount": 100.00,
  "goodsSum": 1,
  "lockStatus": false,
  "needInvoice": true,
  "oaid": "1P9GXXtE9wZx55wlqb9mg1R9WicdCCk9COKyuxmBRYa8icJJxNNS9VoziasZicTGKfv95YnXvqC",
  "orderConsignee": {
    "consigneeAddress": "海山街道梧桐海景苑测试sit",
    "consigneeArea": "盐田区",
    "consigneeCity": "深圳市",
    "consigneeCountry": "",
    "consigneeMobile": "15794977078-1833",
    "consigneeMobileExpireTime": "2025-11-16 23:59:59",
    "consigneeName": "th-测试sit",
    "consigneeProvince": "广东省",
    "consigneeStr": "姓名:th-测试sit,手机: 15794977078-1833,电话: null,省: 广东省,市: 深圳市,区: 盐田区,街道: 海山街道,地址: 海山街道梧桐海景苑测试sit,邮编: 000000.",
    "consigneeStreet": "海山街道",
    "consigneeZipcode": "000000"
  },
  "orderExpand": {
    "consigneeMobileExpireTime": "2025-11-16 23:59:59"
  },
  "orderInvoice": {
    "invoiceAmount": 100.00,
    "invoiceApplyTime": "2025-10-17 16:44:37",
    "invoiceKind": "ELECTRONIC_INVOICES",
    "invoiceTitle": "个人",
    "invoiceTitleType": "CUSTOMER"
  },
  "orderItems": [
    {
      "buyerPaidAmount": 100.00,
      "buyerPrice": 100.00,
      "channelRefundStatus": "NO_REFUND",
      "channelSkuId": "6116107691450",
      "divideOrderDiscountFee": 0,
      "dividePaymentDiscountFee": 0,
      "divideSubsidyFee": 0.00,
      "executePrice": 100.00,
      "goodsAmount": 100.00,
      "goodsDiscountsFee": 0.00,
      "goodsName": "【BSCS】周大福测试链接 请勿拍下 拍下不发货 款式:测试-10.17;重量:0.01g",
      "goodsPic": "https://img.alicdn.com/bao/uploaded/i4/407700539/O1CN01rpbVCD1FquXi3BYqv_!!4611686018427380795-2-item_pic.png",
      "goodsPrice": 100.00,
      "isGift": false,
      "moduleNumber": "测试链接",
      "outerOrderItemId": "4814612391185777730",
      "paidAmount": 100.00,
      "payment": 100.00,
      "quantity": 1,
      "sellingMode": "NORMAL",
      "xcode": "X008VE0002801"
    }
  ],
  "orderPayStatus": "ACCOUNT_PAID",
  "orderPromotions": [],
  "orderStatus": "PAID",
  "orderTotalFee": 100.00,
  "orderType": "ROUTINE_SALES_ORDER",
  "outerCreateTime": "2025-10-17 16:44:36",
  "outerOrderId": "4814612391185777730",
  "outerUpdateTime": "2025-10-17 16:44:38",
  "paidAmount": 100.00,
  "payTime": "2025-10-17 16:44:37",
  "paymentDiscountAmount": 0.00,
  "platformSubsidyFee": 0.00,
  "preorderStatus": "WAIT_AUDIT",
  "serviceChargeFee": 0.00,
  "shopId": "60584",
  "shopName": "周大福官方旗舰店"
}
``` 

## 平台赠品
``` json
{
  "approveInvoiceFlag": false,
  "buyerNick": "我**",
  "cancelTime": "2025-10-20 15:07:57",
  "channelId": 1000,
  "discountAmount": 0.00,
  "freightFee": 0.00,
  "freightInsuranceFee": 0,
  "goodsAmount": 100.01,
  "goodsSum": 2,
  "lockStatus": false,
  "needInvoice": true,
  "oaid": "1P9GXXtE9wZx55wlqb9mg1R9WicdCCk9COKyuxmBRYa8icJJxNNThlSdTo2OI3hUEBlHd5gVH",
  "orderConsignee": {
    "consigneeAddress": "海*街道梧桐海景苑测试***",
    "consigneeArea": "盐田区",
    "consigneeCity": "深圳市",
    "consigneeCountry": "",
    "consigneeMobile": "***********",
    "consigneeName": "t**",
    "consigneeProvince": "广东省",
    "consigneeStr": "姓名:t**,手机: ***********,电话: null,省: 广东省,市: 深圳市,区: 盐田区,街道: 海山街道,地址: 海*街道梧桐海景苑测试***,邮编: 000000.",
    "consigneeStreet": "海山街道",
    "consigneeZipcode": "000000"
  },
  "orderExpand": {},
  "orderInvoice": {
    "invoiceApplyTime": "2025-10-20 15:07:57",
    "invoiceKind": "ELECTRONIC_INVOICES",
    "invoiceTitle": "科码先锋（广州）软件技术有限公司",
    "invoiceTitleType": "COMPANY",
    "payerRegisterNo": "91440101MA9Y4PMY2C"
  },
  "orderItems": [
    {
      "buyerPrice": 0.01,
      "channelRefundStatus": "SUCCESS",
      "channelSkuId": "115885",
      "divideOrderDiscountFee": 0,
      "dividePaymentDiscountFee": 0,
      "divideSubsidyFee": 0.00,
      "executePrice": 0.00,
      "goodsAmount": 0.01,
      "goodsDiscountsFee": 0.01,
      "goodsName": "【BSCS】周大福ZP2测试链接 请勿拍下 拍下不发 null",
      "goodsPic": "https://img.alicdn.com/bao/uploaded/i4/407700539/O1CN016w3X871FquXhmdwnA_!!4611686018427380795-2-item_pic.png",
      "goodsPrice": 0.01,
      "isGift": true,
      "moduleNumber": "115885",
      "outerOrderItemId": "4821277033521777730",
      "paidAmount": 0.00,
      "parenId": "4821277033520777730",
      "payment": 0.00,
      "quantity": 1,
      "sellingMode": "NORMAL",
      "xcode": "115885"
    },
    {
      "buyerPrice": 100.00,
      "channelRefundStatus": "NO_REFUND",
      "channelSkuId": "6112177051726",
      "divideOrderDiscountFee": 0,
      "dividePaymentDiscountFee": 0,
      "divideSubsidyFee": 0.00,
      "executePrice": 0.00,
      "goodsAmount": 100.00,
      "goodsDiscountsFee": 0.00,
      "goodsName": "【BSCS】周大福测试链接 请勿拍下 拍下不发货 款式:赠品测试-10.17;重量:0.01g",
      "goodsPic": "https://img.alicdn.com/bao/uploaded/i4/407700539/O1CN01rpbVCD1FquXi3BYqv_!!4611686018427380795-2-item_pic.png",
      "goodsPrice": 100.00,
      "isGift": false,
      "moduleNumber": "测试链接",
      "outerOrderItemId": "4821277033520777730",
      "paidAmount": 100.00,
      "payment": 0.00,
      "quantity": 1,
      "sellingMode": "NORMAL",
      "xcode": "X001EAU005605"
    }
  ],
  "orderPayStatus": "ACCOUNT_PAID",
  "orderPromotions": [
    {
      "channelActiveId": "tmallItemFreeGift-122115843635_2482568307313",
      "discountAmount": 0.00,
      "promotionDesc": "测试品活动-1017:省0.00元",
      "promotionName": "测试品活动-1017"
    }
  ],
  "orderStatus": "PAID",
  "orderTotalFee": 100.00,
  "orderType": "ROUTINE_SALES_ORDER",
  "outerCreateTime": "2025-10-20 15:07:43",
  "outerOrderId": "4821277033519777730",
  "outerUpdateTime": "2025-10-20 15:09:17",
  "paidAmount": 100.00,
  "payTime": "2025-10-20 15:07:45",
  "paymentDiscountAmount": 0,
  "platformSubsidyFee": 0.00,
  "preorderStatus": "WAIT_AUDIT",
  "shopId": "60584",
  "shopName": "周大福官方旗舰店",
  "signTime": "2025-10-20 15:07:57"
}
```

- 更换赠品编码测试未匹配到平台赠品
- 编辑库存测试库存可售数不足
- 修改赠品编码（215885）测试赠品主数据不存在