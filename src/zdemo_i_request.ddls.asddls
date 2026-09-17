@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analysis Request - Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZDEMO_I_Request
  as select from zdemo_rap_req_h
  composition [0..*] of ZDEMO_I_RequestItem as _Item
{
  key request_uuid as RequestUuid,
      title as Title,
      area as Area,
      priority as Priority,
      status as Status,
      required_date as RequiredDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_amount as TotalAmount,
      currency_code as CurrencyCode,
      created_by as CreatedBy,
      created_at as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      _Item
}
