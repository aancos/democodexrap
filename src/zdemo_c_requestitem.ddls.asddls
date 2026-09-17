@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analysis Request Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZDEMO_C_RequestItem
  as projection on ZDEMO_I_RequestItem
{
  key RequestUuid,
  key ItemUuid,
      ItemNumber,
      Description,
      Quantity,
      Unit,
      EstimatedCost,
      CurrencyCode,
      Status,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Request : redirected to parent ZDEMO_C_Request
}
