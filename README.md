# Apple Design Skill

Skill portable que enseña a un agente de IA a construir interfaces que se ven y se sienten como del ecosistema Apple (iOS 26, iPadOS 26, macOS Tahoe 26, watchOS 26, tvOS 26, visionOS 26): material **Liquid Glass**, tipografía **SF**, paleta y semántica de color del sistema, **SF Symbols**, espaciado, motion y accesibilidad — todo basado en los tres principios de WWDC25 (**Hierarchy**, **Harmony**, **Consistency**).

Genera código tanto **nativo** (SwiftUI / UIKit / AppKit) como **web** (HTML + CSS + SVG, opcionalmente React/Vue/Svelte).

---

## Contenido

```
apple-design-skill/
├── SKILL.md                       Punto de entrada (frontmatter + reglas + índice)
├── references/                    Documentos profundos cargables a demanda
│   ├── interface-fundamentals.md
│   ├── liquid-glass-spec.md
│   ├── swiftui-implementation.md
│   ├── web-implementation.md
│   ├── typography-color-icons.md
│   ├── layout-spacing-motion.md
│   ├── accessibility.md
│   └── platform-cheatsheet.md
├── assets/                        Recursos drop-in
│   ├── liquid-glass.css
│   ├── liquid-glass-filter.svg
│   ├── AppleGlass.swift
│   └── example.html
└── README.md                      Este archivo
```

---

## Inicio rápido (Claude Code en Windows)

Tres comandos. Los detalles completos están más abajo.

```bash
# 1. Crear la carpeta de skills si no existe
mkdir -p "$USERPROFILE/.claude/skills"

# 2. Copiar la skill al directorio de usuario de Claude Code
cp -r "C:/Users/Botinfy/dev/apple-design-skill" "$USERPROFILE/.claude/skills/apple-design"

# 3. Reiniciar Claude Code y verificar
#    (ver sección "Verificación")
```

En PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "C:\Users\Botinfy\dev\apple-design-skill" "$env:USERPROFILE\.claude\skills\apple-design"
```

---

## Instalación en Claude Code

Claude Code descubre skills automáticamente en dos ubicaciones. Elige una según el alcance que necesites.

### Opción A — Alcance de usuario (recomendado)

La skill queda disponible en **todos** los proyectos.

**Ruta destino:**
- Windows: `%USERPROFILE%\.claude\skills\apple-design\`
- macOS / Linux: `~/.claude/skills/apple-design/`

**Bash / Git Bash (Windows):**
```bash
mkdir -p "$USERPROFILE/.claude/skills"
cp -r "C:/Users/Botinfy/dev/apple-design-skill" "$USERPROFILE/.claude/skills/apple-design"
```

**PowerShell (Windows):**
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "C:\Users\Botinfy\dev\apple-design-skill" "$env:USERPROFILE\.claude\skills\apple-design"
```

**macOS / Linux:**
```bash
mkdir -p ~/.claude/skills
cp -R /ruta/a/apple-design-skill ~/.claude/skills/apple-design
```

**Symlink en lugar de copiar** (mantiene la skill sincronizada con la fuente):

- macOS / Linux:
  ```bash
  ln -s /ruta/a/apple-design-skill ~/.claude/skills/apple-design
  ```
- Windows (PowerShell con permisos de administrador):
  ```powershell
  New-Item -ItemType SymbolicLink `
           -Path "$env:USERPROFILE\.claude\skills\apple-design" `
           -Target "C:\Users\Botinfy\dev\apple-design-skill"
  ```
- Windows sin admin (junction):
  ```powershell
  cmd /c mklink /J "$env:USERPROFILE\.claude\skills\apple-design" "C:\Users\Botinfy\dev\apple-design-skill"
  ```

### Opción B — Alcance de proyecto

La skill queda disponible **solo en un repositorio**. Útil cuando es para un cliente o un stack específico.

```bash
mkdir -p <tu-repo>/.claude/skills
cp -r /ruta/a/apple-design-skill <tu-repo>/.claude/skills/apple-design
```

Inclúyela en el control de versiones si quieres que el equipo la use.

### Verificación

1. Abre Claude Code en cualquier proyecto.
2. Pídele: "lista las skills disponibles" — `apple-design` debería aparecer.
3. Prueba un trigger: "diseña un tab bar tipo iOS 26 con Liquid Glass para esta web". El agente debería invocar la skill antes de escribir código.

Si no aparece, comprueba que:
- La carpeta se llama exactamente `apple-design` (no `apple-design-skill`).
- Existe `SKILL.md` en la raíz (no anidado).
- El `SKILL.md` tiene frontmatter YAML válido (`---` … `---`).

---

## Instalación en otros agentes de IA

### Cursor / Codex CLI / GitHub Copilot / Windsurf — vía `AGENTS.md`

`AGENTS.md` es una convención adoptada por Cursor, Codex CLI de OpenAI, GitHub Copilot y Windsurf: el agente lee ese archivo en la raíz del proyecto como instrucciones de contexto.

1. Copia la carpeta `apple-design-skill/` al repositorio (en la raíz o donde prefieras).
2. Crea un `AGENTS.md` en la raíz del repositorio con este contenido:

   ```markdown
   # Apple Design — instrucciones para el agente

   Cuando el usuario pida UI estilo Apple (iOS 26, macOS Tahoe, Liquid Glass,
   SwiftUI .glassEffect, frosted glass tipo Apple, SF Pro), sigue las reglas
   y referencias en `apple-design-skill/`.

   - Punto de entrada: `apple-design-skill/SKILL.md` (léelo primero).
   - Spec de Liquid Glass: `apple-design-skill/references/liquid-glass-spec.md`.
   - Implementación nativa: `apple-design-skill/references/swiftui-implementation.md`.
   - Implementación web: `apple-design-skill/references/web-implementation.md`.
   - Tipografía / color / iconos: `apple-design-skill/references/typography-color-icons.md`.
   - Accesibilidad (checklist obligatoria): `apple-design-skill/references/accessibility.md`.
   - CSS drop-in: `apple-design-skill/assets/liquid-glass.css`.
   - SVG drop-in: `apple-design-skill/assets/liquid-glass-filter.svg`.

   Para tareas no relacionadas con UI estilo Apple, ignora esta sección.
   ```

3. **Cursor** también reconoce `.cursor/rules/*.mdc` con frontmatter:

   ```markdown
   ---
   description: Apple-style UI with Liquid Glass
   globs: ["**/*.tsx", "**/*.swift", "**/*.css"]
   alwaysApply: false
   ---
   Cuando se pida UI estilo Apple, leer apple-design-skill/SKILL.md y seguir
   sus referencias.
   ```

   Guárdalo como `.cursor/rules/apple-design.mdc`.

### Cline / Roo Code (VS Code)

1. Copia `apple-design-skill/` al repositorio.
2. En VS Code → Settings → Cline (o Roo Code) → **Custom Instructions** pega:

   ```
   When the user asks for Apple-style UI (iOS 26, macOS Tahoe, Liquid Glass,
   SwiftUI .glassEffect, SF Pro, frosted glass like Apple), read
   apple-design-skill/SKILL.md and the relevant files under
   apple-design-skill/references/ before generating code. Use the drop-in
   assets in apple-design-skill/assets/ when applicable.
   ```

### Aider

```bash
# Cargar la skill cada vez que se inicia Aider en este repositorio:
aider --read apple-design-skill/SKILL.md \
      --read apple-design-skill/references/interface-fundamentals.md \
      --read apple-design-skill/references/liquid-glass-spec.md
```

O dejarlo permanente en `.aider.conf.yml`:

```yaml
read:
  - apple-design-skill/SKILL.md
  - apple-design-skill/references/interface-fundamentals.md
  - apple-design-skill/references/liquid-glass-spec.md
```

### Continue.dev

En `~/.continue/config.yaml`:

```yaml
rules:
  - name: apple-design
    rule: |
      Para UI estilo Apple (iOS 26, macOS Tahoe, Liquid Glass), sigue las
      reglas y referencias en apple-design-skill/SKILL.md.
    globs: ["**/*.tsx", "**/*.swift", "**/*.css"]
```

### Claude.ai (web — Projects)

1. Crear un Project nuevo en claude.ai.
2. En **Project Knowledge**, sube estos archivos (drag & drop):
   - `SKILL.md`
   - Todos los archivos de `references/`
   - `assets/liquid-glass.css` y `assets/liquid-glass-filter.svg` (opcional, como referencia)
3. En **Custom instructions** del Project pega:

   ```
   Eres experto en el sistema de diseño de Apple (iOS 26 / macOS Tahoe).
   Sigue las reglas de SKILL.md y consulta las referencias relevantes antes
   de generar código. Produce código nativo (SwiftUI/UIKit) o web (CSS+SVG)
   según el stack del usuario.
   ```

### Anthropic API / SDK (programático)

```python
import anthropic
from pathlib import Path

skill_dir = Path("apple-design-skill")
system_prompt = (skill_dir / "SKILL.md").read_text(encoding="utf-8")

# Cargar referencias on-demand para reducir tokens. Para una sesión
# completa, se pueden concatenar las que se necesiten:
for ref in ["interface-fundamentals", "liquid-glass-spec",
            "web-implementation", "accessibility"]:
    system_prompt += "\n\n---\n\n"
    system_prompt += (skill_dir / "references" / f"{ref}.md").read_text(encoding="utf-8")

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    system=[
        {"type": "text", "text": system_prompt,
         "cache_control": {"type": "ephemeral"}}  # prompt caching
    ],
    messages=[{"role": "user",
               "content": "Diseña un tab bar iOS 26 con Liquid Glass."}]
)
print(response.content[0].text)
```

Con prompt caching (`cache_control`) la skill se cachea y los siguientes mensajes en la sesión la leen instantáneamente.

### ChatGPT — Custom GPT

1. Crea un GPT nuevo en https://chat.openai.com/gpts/editor.
2. **Knowledge** → sube todos los archivos de `references/` y `SKILL.md`.
3. **Instructions** pega:

   ```
   Eres experto en el sistema de diseño de Apple (iOS 26 / macOS Tahoe 26).
   Cuando el usuario pida UI estilo Apple — Liquid Glass, SwiftUI, frosted
   glass, SF Pro — consulta los archivos de Knowledge antes de generar
   código. Sigue los tres principios (Hierarchy, Harmony, Consistency) y la
   spec de Liquid Glass. Produce código nativo o web según el stack.
   ```

### Cualquier LLM con system prompt

El patrón general:

1. Leer `SKILL.md` y cargarlo como **system prompt** o como mensaje de sistema.
2. Leer las referencias bajo `references/` **on-demand** según el tipo de tarea (no incluir todo siempre — son mucho contexto).
3. Mantener `assets/` accesible al agente para que pueda referenciarlo o copiarlo a un proyecto.

Pseudocódigo:

```
on_user_request(message):
  system = read("apple-design-skill/SKILL.md")
  if "swift" in message or "ios" in message:
      system += read("apple-design-skill/references/swiftui-implementation.md")
  elif "css" in message or "react" in message or "html" in message:
      system += read("apple-design-skill/references/web-implementation.md")
  system += read("apple-design-skill/references/liquid-glass-spec.md")
  system += read("apple-design-skill/references/accessibility.md")
  agent.run(system=system, user=message)
```

---

## Verificación rápida

Después de instalar, prueba uno de estos prompts. El agente debe consultar la skill **antes** de escribir código:

- "Diseña un tab bar inferior para mi app web con Liquid Glass al estilo iOS 26."
- "Convierte esta card a Liquid Glass `regular`, manteniendo accesibilidad."
- "¿Cómo aplico `.glassEffect` correctamente a un cluster de botones flotantes en SwiftUI?"
- "Dame un toolbar superior tipo macOS Tahoe en CSS, con caída a opaco para Reduce Transparency."

Lo que debería pasar:
- El agente menciona o lee `SKILL.md` o alguno de los archivos en `references/`.
- Aplica los tres principios (Hierarchy, Harmony, Consistency).
- Respeta las reglas de Liquid Glass (no glass-on-glass, no glass en contenido, container cuando hay varios).
- Incluye media queries de accesibilidad (`prefers-reduced-transparency`, `prefers-reduced-motion`) en código web, o `@Environment(\.accessibilityReduceTransparency)` en Swift.
- Usa la paleta semántica del sistema, no hex hardcodeados.

Si no hace nada de eso, la skill no se cargó — revisa la ruta de instalación.

---

## Demo en vivo

Abre `assets/example.html` en un navegador. Verás:
- toolbar superior con Liquid Glass
- tab bar inferior que se minimiza al hacer scroll
- cards en glass `regular` y `clear`
- una card con la variante refractiva (Liquid Glass completo en Chromium; fallback a frosted en Safari/Firefox)
- cluster flotante expandible

Pruebas recomendadas:
- alterna el modo oscuro del sistema operativo
- activa **Reduce Transparency** en el sistema operativo → la skill cumple, el glass se vuelve opaco
- activa **Reduce Motion** → el cluster deja de animarse con spring

---

## Actualizar la skill

Si copiaste la carpeta:

```bash
# Bash / Git Bash
rm -rf "$USERPROFILE/.claude/skills/apple-design"
cp -r "C:/Users/Botinfy/dev/apple-design-skill" "$USERPROFILE/.claude/skills/apple-design"
```

```powershell
# PowerShell
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\apple-design"
Copy-Item -Recurse -Force "C:\Users\Botinfy\dev\apple-design-skill" "$env:USERPROFILE\.claude\skills\apple-design"
```

Si usaste un symlink o junction, los cambios se reflejan automáticamente.

---

## Desinstalación

```bash
rm -rf "$USERPROFILE/.claude/skills/apple-design"
```

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\apple-design"
```

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| Claude Code no lista la skill | La carpeta no está en `~/.claude/skills/` o tiene otro nombre | Verifica la ruta exacta y que la carpeta se llame `apple-design` |
| El agente la lista pero no la usa | El usuario no usó un trigger del frontmatter | Pide explícitamente "usa la skill apple-design" o emplea las palabras clave (Liquid Glass, iOS 26, etc.) |
| Falla `SKILL.md` con error de YAML | Frontmatter mal formado | Abre `SKILL.md` y verifica que comience con `---` y cierre con `---` antes del cuerpo |
| El refractivo no funciona en Safari | Safari no soporta `backdrop-filter: url(#...)` | Es esperado — cae automáticamente a frosted blur. Solo Chromium muestra el efecto completo |
| Mucho consumo de batería en mobile | Demasiados elementos con SVG filter | Reserva `glass--refractive` para 1–2 elementos hero por página; el resto usa la frosted simple |
| El glass se ve opaco en mi navegador | El usuario tiene Reduce Transparency activo | Es el comportamiento correcto y obligatorio — la skill cumple accesibilidad |

---

## Estructura técnica de la skill

`SKILL.md` usa el formato estándar de Claude Code:

```yaml
---
name: apple-design
description: <triggers + cuándo usar / no usar>
---
```

Las referencias bajo `references/` no se cargan automáticamente — el agente las lee a demanda según el índice listado al final de `SKILL.md`. Esto mantiene el contexto ligero: solo se carga lo que la tarea actual necesita.

Los assets bajo `assets/` están listos para copiar tal cual a un proyecto destino. No requieren build.

---

## Créditos

Sintetizada el **2026-04-27** a partir de:
- Apple Newsroom — *Apple introduces a delightful and elegant new software design* (junio 2025).
- Apple Developer Documentation — Interface Fundamentals, Liquid Glass, Adopting Liquid Glass, HIG (foundations + components).
- WWDC25 sesión 356 — *Get to know the new design system*.
- conorluddy/LiquidGlassReference (referencia oro Swift/SwiftUI para IA).
- nikdelvin/liquid-glass (implementación CSS + SVG).
- LogRocket, kube.io, Josh W. Comeau (técnicas web).
- createwithswift.com (desglose Hierarchy/Harmony/Consistency).
- Wikipedia — Liquid Glass (historia y recepción).

---

## Licencia

Esta skill es contenido derivado público (documentación, especificaciones y patrones de diseño Apple, técnicas CSS/SVG abiertas). Úsala, modifícala y distribúyela libremente.

Las **fuentes de Apple** (SF Pro, SF Compact, SF Mono, New York) y los **SF Symbols** tienen sus propias licencias — lee los términos en https://developer.apple.com/fonts/ y https://developer.apple.com/sf-symbols/ antes de embeber esos recursos en proyectos no-Apple.
