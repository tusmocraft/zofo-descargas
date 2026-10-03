#!/bin/bash
# ============================================
#  ZOFO LAUNCHER - Instalador automático
#  Uso: bash instalar.sh
#  O:   curl -sL https://raw.githubusercontent.com/tusmocraft/zofo-descargas/main/instalar.sh | bash
# ============================================
set -e

REPO="tusmocraft/zofo-descargas"
APPS_DIR="$HOME/Applications"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
APPIMAGE="$APPS_DIR/Zofo-Launcher.AppImage"

echo ""
echo "  ███████ ZOFO LAUNCHER - INSTALADOR ███████"
echo ""

# ---- 1. Buscar la URL del AppImage más reciente ----
echo "[1/5] Buscando ultima version en GitHub..."
URL=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o '"browser_download_url": *"[^"]*\.AppImage"' \
  | head -1 | cut -d'"' -f4)

if [ -z "$URL" ]; then
  echo "ERROR: No se encontro la AppImage en GitHub."
  echo "Revisa tu conexion o que exista un release en github.com/$REPO/releases"
  exit 1
fi

VERSION=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
echo "      Version encontrada: $VERSION"

# ---- 2. Descargar ----
echo "[2/5] Descargando Zofo Launcher..."
mkdir -p "$APPS_DIR"
curl -L --progress-bar "$URL" -o "$APPIMAGE"
chmod +x "$APPIMAGE"
echo "      Guardado en $APPIMAGE"

# ---- 3. Extraer icono ----
echo "[3/5] Instalando icono..."
mkdir -p "$ICON_DIR"
TMP=$(mktemp -d)
cd "$TMP"
"$APPIMAGE" --appimage-extract >/dev/null 2>&1 || true
# Buscar el icono mas grande disponible
ICON=$(find squashfs-root -name '*.png' -size +8k 2>/dev/null | sort | tail -1)
if [ -n "$ICON" ]; then
  cp "$ICON" "$ICON_DIR/zofo-launcher.png"
fi
cd - >/dev/null
rm -rf "$TMP"

# ---- 4. Acceso directo en el menu de aplicaciones ----
echo "[4/5] Creando acceso directo..."
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/zofo-launcher.desktop" << EOF
[Desktop Entry]
Name=Zofo Launcher
Comment=Minecraft 1.21.11 - Zofo Productions
Exec=$APPIMAGE
Icon=zofo-launcher
Type=Application
Categories=Game;
Terminal=false
EOF

update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# Acceso directo tambien en el escritorio si existe
for D in "$HOME/Desktop" "$HOME/Escritorio"; do
  if [ -d "$D" ]; then
    cp "$DESKTOP_DIR/zofo-launcher.desktop" "$D/Zofo Launcher.desktop"
    chmod +x "$D/Zofo Launcher.desktop"
  fi
done

# ---- 5. Listo ----
echo "[5/5] Instalacion completada."
echo ""
echo "  =========================================="
echo "   ZOFO LAUNCHER INSTALADO v$VERSION"
echo "  =========================================="
echo ""
echo "  Puedes abrirlo desde:"
echo "   - El menu de aplicaciones (busca 'Zofo Launcher')"
echo "   - El icono en tu escritorio"
echo "   - La terminal: ~/Applications/Zofo-Launcher.AppImage"
echo ""
echo "  El launcher se ACTUALIZA SOLO. No tienes que"
echo "  volver a instalar nada."
echo ""
