@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analysis Request Item - Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDEMO_I_RequestItem
  as select from zdemo_rap_req_i
  association to parent ZDEMO_I_Request as _Request
    on $projection.RequestUuid = _Request.RequestUuid
{
  key request_uuid as RequestUuid,
  key item_uuid as ItemUuid,
      item_number as ItemNumber,
      description as Description,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      quantity as Quantity,
      unit as Unit,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      estimated_cost as EstimatedCost,
      currency_code as CurrencyCode,
      status as Status,
      created_by as CreatedBy,
      created_at as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      _Request
}
