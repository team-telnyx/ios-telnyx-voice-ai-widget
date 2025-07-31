# Instrucciones para agregar dependencia SPM a SampleApp

## Pasos para agregar TelnyxVoiceAIWidget como dependencia SPM en SampleApp:

1. **Abrir el workspace**: `TelnyxVoiceAIWidget.xcworkspace`

2. **Seleccionar el proyecto SampleApp** en el navigator

3. **Ir a Project Settings** → SampleApp target → Package Dependencies

4. **Click en "+"** para agregar nueva dependencia

5. **Agregar la dependencia local**:
   - En "Add Package Dependency", seleccionar "Add Local..."
   - Navegar hasta la carpeta raíz del proyecto (donde está Package.swift)
   - Seleccionar la carpeta y hacer click en "Add Package"

6. **Configurar la dependencia**:
   - Seleccionar "TelnyxVoiceAIWidget" como product
   - Hacer click en "Add Package"

7. **Verificar la importación**: 
   - El SDK debería aparecer en Package Dependencies
   - ContentView.swift ya está configurado para usar el SDK

## Alternativa usando URL del repositorio:

Si prefieres usar la URL del repositorio remoto:
1. En lugar de "Add Local", usar "Add Package Dependency"
2. Ingresar: `https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git`
3. Seleccionar la versión deseada (1.0.0)

## Verificación:

Una vez agregada la dependencia, la SampleApp debería:
- Compilar sin errores
- Mostrar la versión del SDK: "1.0.0"
- Permitir inicializar el SDK y comenzar sesiones de voz

## Estructura final del workspace:

```
TelnyxVoiceAIWidget.xcworkspace
├── TelnyxVoiceAIWidget (SDK)
└── SampleApp (Demo App que consume el SDK)
```
