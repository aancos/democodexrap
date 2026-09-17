@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analysis Requests'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZDEMO_C_Request
  provider contract transactional_query
  as projection on ZDEMO_I_Request
{
  key RequestUuid,
      @Search.defaultSearchElement: true
      Title,
      Area,
      Priority,
      Status,
      RequiredDate,
      TotalAmount,
      CurrencyCode,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Item : redirected to composition child ZDEMO_C_RequestItem
}
