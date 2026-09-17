# Demo ABAP RAP: solicitudes de análisis

Aplicación de referencia ABAP RESTful Application Programming Model (RAP) para gestionar solicitudes con cabecera y posiciones. Incluye BO administrado, validaciones, determinaciones, acciones y servicio OData V4 preparado para SAP Fiori elements.

El repositorio usa el formato nativo de abapGit para ABAP Platform 2025. El service binding se crea y publica después del pull porque su serialización incluye artefactos técnicos generados y dependientes del sistema.

## Funcionalidad

- Cabecera: título, área, prioridad, estado, fecha requerida, moneda e importe total.
- Posiciones: descripción, cantidad, unidad, coste estimado y estado.
- Estados: `N` Nueva, `P` En proceso, `A` Aprobada y `R` Rechazada.
- Título y área obligatorios.
- La fecha requerida no puede ser anterior a la fecha del sistema.
- Solo solicitudes `N` o `P` pueden aprobarse o rechazarse.
- Una solicitud sin posiciones no puede aprobarse.
- El total se recalcula durante la secuencia de guardado al crear, cambiar o borrar posiciones.

## Arquitectura

```text
Servicio OData V4: ZDEMO_UI_REQUEST
            |
Proyección: ZDEMO_C_Request / ZDEMO_C_RequestItem
            |
BO RAP: ZDEMO_I_Request / ZDEMO_I_RequestItem
            |
Persistencia: ZDEMO_RAP_REQ_H / ZDEMO_RAP_REQ_I
```

El comportamiento se implementa en `ZBP_DEMO_I_REQUEST`. Las acciones `Approve` y `Reject` controlan la transición de estado. `RecalculateTotal` agrega `EstimatedCost` de las posiciones activas del buffer transaccional. Los campos técnicos usan tipos RAP estándar para auditoría, ETag y draft.

## Objetos

| Tipo | Objeto | Finalidad |
|---|---|---|
| Tabla | `ZDEMO_RAP_REQ_H` | Persistencia de cabecera |
| Tabla | `ZDEMO_RAP_REQ_I` | Persistencia de posiciones |
| CDS | `ZDEMO_I_Request` | Entidad interfaz raíz |
| CDS | `ZDEMO_I_RequestItem` | Entidad interfaz hija |
| BDEF | `ZDEMO_I_Request` | Comportamiento administrado |
| Clase | `ZBP_DEMO_I_REQUEST` | Validaciones, determinaciones y acciones |
| CDS | `ZDEMO_C_Request*` | Proyecciones de consumo |
| Metadata extensions | `ZDEMO_C_Request*` | UI de Fiori elements |
| Service definition | `ZDEMO_UI_REQUEST` | Exposición del BO |
| Service binding | `ZDEMO_UI_REQUEST_O4` | OData V4 UI; se crea/publica en ADT |

## Instalación y activación

Destino comprobado: SAP S/4HANA 2025 FPS01, ABAP Platform 2025 SP01, ADT actualizado y un paquete transportable.

1. Ejecute `ZABAPGIT` y seleccione **New Online**.
2. Use la URL `https://github.com/aancos/democodexrap.git` y un paquete vacío, por ejemplo `ZDEMO_RAP_REQUEST`.
3. Cree el repositorio online y ejecute **Pull**. En un paquete transportable, seleccione una orden Workbench cuando se solicite.
4. Revise el log de activación; los objetos se incluyen con sus metadatos abapGit.
5. En ADT, cree el service binding `ZDEMO_UI_REQUEST_O4`, tipo **OData V4 - UI**, añada `ZDEMO_UI_REQUEST`, active y publique.
6. Abra **Preview** sobre `Requests` para ejecutar la aplicación Fiori elements.

### Primera instalación cuando la activación cíclica falla

En algunos sistemas, la activación masiva de abapGit no resuelve inicialmente el ciclo entre la composición de cabecera y la asociación al padre de las posiciones. Si las entidades aparecen como desconocidas, realice una activación inicial de las cuatro vistas CDS con estas relaciones temporalmente comentadas: composición `_Item`, asociación `_Request` y sus dos redirecciones en las proyecciones. Después restáurelas y active otra vez en el orden indicado abajo. Este procedimiento solo es necesario para crear la primera versión activa; las actualizaciones posteriores conservan las dependencias correctamente.

## Orden de activación

```text
Tablas -> CDS interfaz -> BDEF interfaz -> behavior pool
       -> CDS proyección -> BDEF proyección -> metadata -> servicio -> binding
```

## Notas productivas

- Sustituya la autorización permisiva de ejemplo por controles DCL y lógica de autorización por instancia.
- Si se permiten monedas distintas entre posiciones, convierta importes antes de agregarlos; esta demo hereda la moneda de la cabecera.
- Adapte longitudes, dominios y textos a las convenciones del sistema objetivo.
- Ejecute ATC con la variante de su landscape antes de transportar.
- Destino validado documentalmente: SAP S/4HANA 2025 FPS01 y ABAP Platform 2025 SP01.

## Licencia

MIT.
