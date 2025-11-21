# Buscador FP Dual - Islas Canarias

**Herramienta profesional de búsqueda y scraping de empresas para docentes de Formación Profesional Dual en las Islas Canarias**

> Busca automáticamente empresas en Google Maps, extrae información de contacto completa y exporta resultados a Excel en cuestión de minutos.

---

## 📋 Tabla de Contenidos

- [¿Qué es?](#qué-es)
- [Características Principales](#características-principales)
- [Funciones Detalladas](#funciones-detalladas)
- [Instalación](#instalación)
- [Uso](#uso)
- [Configuración Avanzada](#configuración-avanzada)
- [Datos Geográficos](#datos-geográficos)
- [FAQ](#faq)

---

## ¿Qué es?

**Buscador FP Dual** es una aplicación web especializada para docentes de Formación Profesional (FP) Dual en las Islas Canarias que necesitan encontrar empresas donde sus estudiantes puedan realizar prácticas.

Automatiza completamente el proceso tedioso de buscar empresas manualmente en Google Maps, permitiendo a los docentes:
- Buscar por familia profesional (26 familias oficiales de FP)
- Seleccionar múltiples municipios simultáneamente
- Extraer datos de contacto automáticamente
- Descargar todo en Excel

**Antes:** Búsquedas manuales, toma de notas, compilación en spreadsheets = **5-10 horas de trabajo**

**Ahora:** Un click y tienes toda la información = **5-10 minutos**

---

## 🎯 Características Principales

### 🗺️ Cobertura Geográfica Completa
- **7 Islas Canarias**: Tenerife, Gran Canaria, Lanzarote, Fuerteventura, La Palma, La Gomera, El Hierro
- **111 Municipios** en total (distribuidos en las 7 islas)
- **Búsqueda inteligente** con contexto geográfico completo (municipio, isla, código postal)

### 👨‍💼 26 Familias Profesionales Oficiales
Acceso a todas las familias de FP en España:

**Familia de Servicios:**
- Actividades Comerciales
- Administración
- Servicios Socioculturales
- Asistencia Social
- Imagen Personal
- Servicios a la Comunidad

**Familia de Industria:**
- Industrias Extractivas
- Fabricación Mecánica
- Industria Agroalimentaria
- Electromecánica
- Industria Energética

**Familia de Construcción:**
- Edificación y Obra Civil
- Montaje y Mantenimiento

**Familia de Tecnología:**
- Informática
- Telecomunicaciones
- Electricidad y Electrónica

**Familia de Turismo y Hostelería:**
- Hostelería y Turismo
- Transporte y Logística
- Venta y Marketing

**Familia de Educación:**
- Imagen y Sonido
- Diseño y Artes Plásticas

**+ "Todas" (búsqueda combinada de todas las familias)**

### 📱 Interfaz de Usuario Intuitiva

#### Dashboard Principal
- **Selector de Isla**: Dropdown para elegir una isla (automáticamente filtra municipios)
- **Selector de Municipios**: Checkboxes agrupados por isla con contador de empresas
- **Selector de Familia Profesional**: 27 opciones configurables
- **Botón Buscar**: Inicia el scraping con validaciones
- **Tabla de Resultados**: Muestra empresas encontradas con paginación

#### Página de Configuración (`/config`)
- **Editar Familias Profesionales**: Cambiar nombres, keywords, descripciones
- **Gestionar Keywords**: Palabras clave para cada familia (ej: "abogado" para familia "Servicios Jurídicos")
- **Exportar/Importar**: Backup y restauración de configuración
- **Personalización**: Adaptar la herramienta a necesidades específicas

---

## 🔧 Funciones Detalladas

### 1️⃣ Búsqueda Inteligente de Empresas

**Cómo funciona:**
```
Selecciona: Familia + Municipio + Isla
            ↓
Script genera búsqueda: "Abogado en Arrecife, Lanzarote, Islas Canarias 35500"
            ↓
Puppeteer abre Google Maps en modo headless
            ↓
Extrae resultados (nombre, categoría, teléfono, dirección)
            ↓
Almacena en base de datos
```

**Características:**
- ✅ Búsqueda por palabra clave con contexto geográfico
- ✅ Múltiples keywords por familia (ej: "abogado", "consultoría legal", "asesoría")
- ✅ Evita duplicados mediante validación de datos
- ✅ Respeta delays para no sobrecargar Google Maps
- ✅ Capaz de procesar 100+ búsquedas sin interrupciones

### 2️⃣ Extracción de Información de Contacto

**Datos extraídos por empresa:**
- 📛 **Nombre**: Nombre de la empresa
- 🏷️ **Categoría**: Tipo de negocio (ej: "Abogado", "Consultoría")
- 📍 **Dirección**: Completa con código postal
- 📞 **Teléfono**: Número de contacto
- 🌐 **Sitio Web**: URL del sitio web (si disponible)
- ✉️ **Email**: Extraído automáticamente del sitio web
- 📍 **Código Postal**: Precisión geográfica
- 🗺️ **Link de Google Maps**: Para verificación manual

**Email Intelligence:**
- Busca automáticamente en la página de inicio
- Intenta la página "Contacto" del sitio
- Extrae emails con validación regex
- Registra estado de completitud (✓ Completo / ⚠️ Parcial)

### 3️⃣ Gestión de Resultados

**Tabla de Resultados:**
- ✅ Muestra hasta 6 empresas por pantalla (scroll vertical)
- ✅ Ordenamiento por estado (Completo / Parcial)
- ✅ Búsqueda y filtrado en tiempo real
- ✅ Expandible para ver detalles completos

**Acciones disponibles:**
- **Exportar a Excel**: Descarga completa con todos los campos
- **Limpiar Resultados**: Borra la base de datos local
- **Ver Detalles**: Abre información completa en modal
- **Validar Datos**: Marca como revisados/verificados

### 4️⃣ Exportación a Excel Profesional

**Archivo generado:**
```
Formato: .xlsx (Excel 2007+)
Columnas:
  - Empresa
  - Categoría
  - Dirección
  - Código Postal
  - Teléfono
  - Sitio Web
  - Email
  - Municipio
  - Isla
  - Estado (Completo/Parcial)
  - Fecha de Búsqueda
  - Link Google Maps

Estilo:
  - Encabezados coloreados (azul profesional)
  - Ancho automático de columnas
  - Filtros activos
  - Protección de hojas
```

### 5️⃣ Configuración de Familias Profesionales

**En la página `/config` puedes:**

**Editar Familia:**
```json
{
  "familyId": "abogado",
  "name": "Servicios Jurídicos",
  "keywords": ["abogado", "abogada", "consultoría legal", "asesoría jurídica"],
  "description": "Profesionales del derecho para asesoría empresarial"
}
```

**Importar/Exportar:**
- Descarga configuración como JSON
- Comparte configuración con otros docentes
- Restaura configuración anterior

**Keywords Personalizadas:**
- Múltiples palabras clave por familia
- Busca en paralelo todos los keywords
- Detecta y elimina duplicados automáticamente

### 6️⃣ Seguimiento en Tiempo Real

**WebSocket Streaming:**
- Conexión en vivo actualiza progreso
- Muestra empresa mientras se descubre
- Actualiza contador: "Procesando 15/45 búsquedas"
- Muestra contexto actual: "Buscando: Abogados en Arrecife, Lanzarote"

**Indicadores de Progreso:**
```
Barra visual: ████████░░░░░░░░ 50%
Empresas encontradas: 34
Búsquedas completadas: 15/30
Estado: Buscando...
```

### 7️⃣ Validación Inteligente

**Antes de iniciar búsqueda:**
- ⚠️ Alerta si ya hay 100+ resultados guardados
- Sugiere limpiar base de datos para evitar mezclar datos
- Opción: "Limpiar y Buscar" o "Buscar de Todas Formas"

**Durante búsqueda:**
- Valida que municipio pertenezca a isla seleccionada
- Previene búsquedas "cross-island"
- Registra errores de conexión

### 8️⃣ Gestión de Isla (Autofocus)

**Comportamiento inteligente:**
```
Usuario selecciona isla → Municipios se actualizan automáticamente
                        → Municipios previos se desmarcan
                        → Previene búsquedas inválidas
```

**7 Islas soportadas:**
1. Tenerife (35 municipios)
2. Gran Canaria (21 municipios)
3. Lanzarote (7 municipios)
4. Fuerteventura (6 municipios)
5. La Palma (14 municipios)
6. La Gomera (6 municipios)
7. El Hierro (3 municipios)

### 9️⃣ Autenticación y Seguridad

**Características de seguridad:**
- Variables de entorno protegidas (.env)
- Credenciales de base de datos en archivo protegido (600 permisos)
- CORS habilitado solo para dominio propio
- Rate limiting en API
- Logs de auditoría

### 🔟 API REST Completa

**Endpoints disponibles:**

```bash
# Scraping
POST   /api/scraper/start      # Inicia búsqueda
POST   /api/scraper/stop       # Detiene búsqueda
GET    /api/scraper/status     # Estado actual

# Leads (resultados)
GET    /api/leads              # Obtiene todos los resultados
DELETE /api/leads              # Limpia base de datos
GET    /api/leads/export       # Descarga Excel

# Familias Profesionales
GET    /api/families           # Obtiene todas las familias
PUT    /api/families/:id       # Edita familia
POST   /api/families/init      # Reinicia valores por defecto

# WebSocket
WS     /ws                     # Stream en tiempo real
```

---

## 🚀 Instalación

### Opción 1: Instalación Automática (Recomendada)

En un servidor Ubuntu/Debian limpio:

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/innovafpiesmmg/buscador-fp-dual/main/install.sh)
```

**Tiempo estimado: 5-10 minutos**

### Opción 2: Instalación Manual

Para más detalles, consulta [INSTALL.md](INSTALL.md)

### Requisitos Mínimos

| Aspecto | Mínimo | Recomendado |
|--------|--------|------------|
| CPU | 1 core | 2+ cores |
| RAM | 2GB | 4GB |
| Almacenamiento | 500MB | 5GB |
| SO | Ubuntu 20.04 | Ubuntu 22.04 LTS |
| Navegador | Chrome/Firefox | Último |

---

## 📖 Uso

### Paso 1: Acceder a la Aplicación

```
http://tu-servidor-ip
o
https://tu-dominio.com
```

### Paso 2: Seleccionar Isla

1. Click en dropdown de isla
2. Elige una de las 7 Islas Canarias
3. Municipios se cargan automáticamente

### Paso 3: Seleccionar Municipios

1. Marca los municipios donde deseas buscar
2. Puedes seleccionar múltiples (ej: 3-5)
3. El contador muestra empresas aproximadas

### Paso 4: Elegir Familia Profesional

1. Dropdown con 26 familias + "Todas"
2. O personaliza en `/config` antes

### Paso 5: Iniciar Búsqueda

1. Click en **"🔍 Buscar"**
2. Se abrirá modal si hay resultados previos
3. Verás progreso en tiempo real
4. **No cierres el navegador** durante búsqueda

### Paso 6: Revisar Resultados

1. Tabla muestra empresas encontradas
2. Puedes clickear empresa para detalles
3. Verde = Información Completa
4. Amarillo = Información Parcial

### Paso 7: Exportar a Excel

1. Click en **"📊 Exportar Excel"**
2. Se descarga automáticamente
3. Archivo listo para usar en clases

---

## ⚙️ Configuración Avanzada

### Personalizar Familias Profesionales

1. Ve a **http://tu-servidor/config**
2. Haz click en familia para editar
3. **Cambiar nombre**: Cómo aparece en la UI
4. **Editar keywords**: Palabras para buscar en Google Maps
5. **Descripción**: Notas sobre la familia
6. **Guardar**: Se sincroniza automáticamente

### Exportar Configuración Personalizada

```bash
# En /config
Click "Exportar JSON"
Descarga archivo configuracion.json
```

### Importar Configuración

```bash
# En /config
Click "Importar JSON"
Selecciona archivo JSON
Se sobrescriben familias automáticamente
```

### Variables de Entorno

Edita `/opt/buscador-fp-dual/.env`:

```env
# Base de datos
DATABASE_URL=postgresql://user:pass@localhost:5432/db
PGUSER=user
PGPASSWORD=pass
PGDATABASE=db

# Aplicación
NODE_ENV=production
PORT=5000

# Scraper (opcional)
PUPPETEER_TIMEOUT=30000        # 30 segundos por página
MAPS_SEARCH_DELAY=1000         # Delay entre búsquedas (ms)
```

---

## 📊 Datos Geográficos

### Estructura de Datos

Cada municipio incluye:
- Nombre oficial
- Código postal
- Isla a la que pertenece
- Localidades incluidas

**Ejemplo - Tenerife:**
```
La Orotava (38300) → 7 localidades
Puerto de la Cruz (38400) → 5 localidades
Santa Cruz de Tenerife (38000) → 10 localidades
...
```

### 111 Municipios Cubiertos

**Por Isla:**
- Tenerife: 35 municipios
- Gran Canaria: 21 municipios
- Lanzarote: 7 municipios
- Fuerteventura: 6 municipios
- La Palma: 14 municipios
- La Gomera: 6 municipios
- El Hierro: 3 municipios

---

## 🐛 Troubleshooting

### Error: "Chrome not found"
✅ Se resuelve automáticamente en primer inicio
```bash
# Si persiste:
npx puppeteer browsers install chrome
```

### Error: "Connection refused" (base de datos)
```bash
# Verifica que PostgreSQL está corriendo:
sudo systemctl status postgresql
```

### Error: "502 Bad Gateway"
```bash
# Verifica que la app está corriendo:
sudo systemctl status buscador-fp-dual

# Ver logs:
sudo tail -f /var/log/buscador-fp-dual/app.log
```

### Búsqueda muy lenta
- Reduce el número de municipios (máximo 5)
- Intenta en horas no pico
- Aumenta delay en `.env`: `MAPS_SEARCH_DELAY=2000`

---

## ❓ FAQ

**P: ¿Qué información se extrae?**
R: Nombre, categoría, dirección, teléfono, sitio web y email (si disponible)

**P: ¿Cuántas empresas por búsqueda?**
R: Variable según municipio y keywords (típicamente 5-30 por búsqueda)

**P: ¿Puedo buscar en múltiples islas?**
R: No simultáneamente (por seguridad), pero puedes hacer búsquedas secuenciales

**P: ¿Los datos se guardan?**
R: Sí, en PostgreSQL local. Puedes limpiar con botón "Limpiar Resultados"

**P: ¿Puedo compartir resultados con colegas?**
R: Sí, exporta Excel y comparte. O pueden ejecutar misma búsqueda

**P: ¿Funciona sin conexión a internet?**
R: No, requiere internet para acceder a Google Maps

**P: ¿Cuánto tarda una búsqueda?**
R: 2-5 minutos típicamente (depende de municipios y keywords)

**P: ¿Hay límites de búsquedas?**
R: No, puedes hacer infinitas. Solo Google Maps tiene rate limits

**P: ¿Puedo automatizar búsquedas?**
R: Sí, via API REST: `POST /api/scraper/start`

---

## 📞 Soporte

- 🐛 **Reportar bugs**: Abre issue en GitHub
- 💡 **Sugerencias**: Discussions en GitHub
- 📧 **Email**: dev@innovafpiesmmg.com

---

## 📄 Licencia

MIT License - Libre para uso comercial y educativo

---

**Hecho con ❤️ para docentes de FP Dual en Canarias**

© 2025 Atreyu Servicios Digitales
