* RAP handlers. This include must be imported and activated with the class pool.
CLASS lhc_Request DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Request RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Request RESULT result.
    METHODS InitializeRequest FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Request~InitializeRequest.
    METHODS ValidateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Request~ValidateMandatoryFields.
    METHODS ValidateRequiredDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Request~ValidateRequiredDate.
    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION Request~Approve RESULT result.
    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION Request~Reject RESULT result.
ENDCLASS.

CLASS lhc_Request IMPLEMENTATION.
  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
      ( %tky = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
        %action-Edit = if_abap_behv=>auth-allowed
        %action-Approve = if_abap_behv=>auth-allowed
        %action-Reject = if_abap_behv=>auth-allowed ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).
    result = VALUE #( FOR request IN requests
      LET can_decide = xsdbool( request-Status = 'N' OR request-Status = 'P' ) IN
      ( %tky = request-%tky
        %action-Approve = COND #( WHEN can_decide = abap_true
                                  THEN if_abap_behv=>fc-o-enabled
                                  ELSE if_abap_behv=>fc-o-disabled )
        %action-Reject = COND #( WHEN can_decide = abap_true
                                 THEN if_abap_behv=>fc-o-enabled
                                 ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD InitializeRequest.
    MODIFY ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request UPDATE FIELDS ( Status Priority CurrencyCode TotalAmount )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky Status = 'N' Priority = 'M'
          CurrencyCode = 'EUR' TotalAmount = 0 ) ).
  ENDMETHOD.

  METHOD ValidateMandatoryFields.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request FIELDS ( Title Area ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).
    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>).
      IF <request>-Title IS INITIAL.
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
        APPEND VALUE #( %tky = <request>-%tky
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = 'El título es obligatorio' )
          %element-Title = if_abap_behv=>mk-on ) TO reported-request.
      ENDIF.
      IF <request>-Area IS INITIAL.
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
        APPEND VALUE #( %tky = <request>-%tky
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = 'El área es obligatoria' )
          %element-Area = if_abap_behv=>mk-on ) TO reported-request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD ValidateRequiredDate.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request FIELDS ( RequiredDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(requests).
    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>)
      WHERE RequiredDate < cl_abap_context_info=>get_system_date( ).
      APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
      APPEND VALUE #( %tky = <request>-%tky
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                      text = 'La fecha requerida no puede ser anterior a hoy' )
        %element-RequiredDate = if_abap_behv=>mk-on ) TO reported-request.
    ENDLOOP.
  ENDMETHOD.

  METHOD Approve.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(requests)
      ENTITY Request BY \_Item FIELDS ( ItemUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(items).
    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>).
      IF <request>-Status <> 'N' AND <request>-Status <> 'P'.
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
        APPEND VALUE #( %tky = <request>-%tky
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = 'Solo solicitudes nuevas o en proceso pueden aprobarse' ) )
          TO reported-request.
        CONTINUE.
      ENDIF.
      IF NOT line_exists( items[ RequestUuid = <request>-RequestUuid ] ).
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
        APPEND VALUE #( %tky = <request>-%tky
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = 'No se puede aprobar una solicitud sin posiciones' ) )
          TO reported-request.
        CONTINUE.
      ENDIF.
      MODIFY ENTITIES OF zdemo_i_request IN LOCAL MODE
        ENTITY Request UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky = <request>-%tky Status = 'A' ) ).
    ENDLOOP.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR request IN updated ( %tky = request-%tky %param = request ) ).
  ENDMETHOD.

  METHOD Reject.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request FIELDS ( Status ) WITH CORRESPONDING #( keys ) RESULT DATA(requests).
    LOOP AT requests ASSIGNING FIELD-SYMBOL(<request>).
      IF <request>-Status <> 'N' AND <request>-Status <> 'P'.
        APPEND VALUE #( %tky = <request>-%tky ) TO failed-request.
        APPEND VALUE #( %tky = <request>-%tky
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = 'Solo solicitudes nuevas o en proceso pueden rechazarse' ) )
          TO reported-request.
        CONTINUE.
      ENDIF.
      MODIFY ENTITIES OF zdemo_i_request IN LOCAL MODE
        ENTITY Request UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky = <request>-%tky Status = 'R' ) ).
    ENDLOOP.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(updated).
    result = VALUE #( FOR request IN updated ( %tky = request-%tky %param = request ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS InitializeItem FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Item~InitializeItem.
    METHODS RecalculateTotal FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~RecalculateTotal.
ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.
  METHOD InitializeItem.
    READ ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Item BY \_Request FIELDS ( CurrencyCode ) WITH CORRESPONDING #( keys )
        RESULT DATA(parents).
    MODIFY ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Item UPDATE FIELDS ( Status CurrencyCode )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky Status = 'N'
          CurrencyCode = VALUE #( parents[ RequestUuid = key-RequestUuid ]-CurrencyCode OPTIONAL ) ) ).
  ENDMETHOD.

METHOD RecalculateTotal.

  DATA request_keys
    TYPE TABLE FOR READ IMPORT zdemo_i_request\_Item.

  request_keys = VALUE #(
    FOR GROUPS request_uuid OF key IN keys
    GROUP BY key-RequestUuid
    (
      RequestUuid = request_uuid
    )
  ).

  READ ENTITIES OF zdemo_i_request IN LOCAL MODE
    ENTITY Request BY \_Item
      FIELDS ( EstimatedCost )
      WITH request_keys
      RESULT DATA(items).

  LOOP AT request_keys ASSIGNING FIELD-SYMBOL(<request_key>).

    DATA total TYPE zdemo_rap_req_h-total_amount.
    CLEAR total.

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>)
      WHERE RequestUuid = <request_key>-RequestUuid.

      total = total + <item>-EstimatedCost.

    ENDLOOP.

    MODIFY ENTITIES OF zdemo_i_request IN LOCAL MODE
      ENTITY Request
        UPDATE FIELDS ( TotalAmount )
        WITH VALUE #(
          (
            RequestUuid = <request_key>-RequestUuid
            TotalAmount = total
          )
        ).

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
