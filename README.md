# AION - Arquitectura del Proyecto

AION es una plataforma de asistencia inteligente construida con **Flutter** siguiendo los principios de **Clean Architecture** y una gestión de estado reactiva con **BLoC**.

## 1. Stack Tecnológico
- **Framework:** Flutter (Stable)
- **Gestión de Estado:** BLoC / Cubit (con HydratedBloc para persistencia).
- **Arquitectura:** Clean Architecture (Feature-driven).
- **Inyección de Dependencias:** GetIt.
- **Navegación:** GoRouter.
- **Backend:** Firebase (Auth & Firestore).

## 2. Estructura de Carpetas
El proyecto se divide en módulos (`features`). Cada módulo contiene:

- **Domain:** La capa más interna. Contiene las reglas de negocio, Entidades y contratos de Repositorios (Interfaces). Es 100% independiente de librerías externas.
- **Data:** Implementación de los contratos del dominio. Contiene Modelos (con lógica JSON), DataSources (Firebase, APIs) y Repositorios.
- **Presentation:** Capa de UI. Contiene los BLoCs, Pages y Widgets específicos de la funcionalidad.

## 3. Requisitos para Desarrolladores (Setup)
Para que este proyecto compile, debes configurar manualmente los siguientes archivos que están ignorados por seguridad:

### Variables de Entorno
Este proyecto utiliza `flutter_dotenv` para manejar datos sensibles. Debes crear un archivo `.env` en la raíz del proyecto con el siguiente formato:

```text
GEMINI_API_KEY=AIzaSy... (Obtenla en Google AI Studio)
```
### Firebase
1. Instalar Firebase CLI y FlutterFire CLI.
2. Ejecutar `flutterfire configure` para generar:
    - `lib/firebase_options.dart`
    - `android/app/google-services.json` (Automático)
    - `ios/Runner/GoogleService-Info.plist` (Automático)

### Bases de Datos
AION utiliza una base de datos de Firestore con el ID `aion`. Asegúrate de tenerla creada en tu consola de Firebase.

## 4. Flujo de Datos
`UI -> BLoC -> Use Case -> Repository (Interface) -> Repository (Impl) -> DataSource -> Firebase`