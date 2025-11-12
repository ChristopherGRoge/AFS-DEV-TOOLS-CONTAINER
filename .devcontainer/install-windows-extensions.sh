#!/bin/bash

# Script to conditionally install VSIX extensions for Windows hosts only
# This script checks if the host OS is Windows by detecting the USERPROFILE environment variable

echo "Checking host OS for conditional extension installation..."

# Check if USERPROFILE is set (Windows-specific environment variable)
if [ -n "$USERPROFILE" ]; then
    echo "Windows host detected. Installing Windows-specific extensions..."

    VSIX_PATH="${containerWorkspaceFolder}/VSIX/afs-code-cred-2.1.0.vsix"

    if [ -f "$VSIX_PATH" ]; then
        echo "Installing afs-code-cred extension from $VSIX_PATH..."

        if code --install-extension "$VSIX_PATH" 2>&1; then
            echo "✓ Successfully installed afs-code-cred extension"
        else
            echo "⚠ WARNING: Failed to install afs-code-cred extension from $VSIX_PATH"
            echo "  The container will continue to start, but the extension may not be available."
        fi
    else
        echo "⚠ WARNING: VSIX file not found at $VSIX_PATH"
        echo "  Expected location: VSIX/afs-code-cred-2.1.0.vsix"
    fi
else
    echo "Non-Windows host detected. Skipping Windows-specific extensions."
fi

echo "Extension installation check complete."
