#!/bin/bash
while true; do
    echo "Menu de choix:"
    echo "1. Installer les depot"
    echo "2. Installer et supprimer les application"
    echo "3. Mettre a jour le systeme"
    echo "4. Quitter"
    
    read -p "Entrez votre choix (1-4): " choix
    
    case $choix in
        1)
            
            if [ "$EUID" -ne 0 ]; then
                echo "Cette fonction dois etre lancer en root ."
                echo "Veuillez réessayer avec: sudo $0"
            else 
                echo "Installation de depot"
                sudo dnf install dnf-plugins-core fedora-workstation-repositories -y -q
                sudo dnf install --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y -q
                sudo dnf install --nogpgcheck https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y -q
                sudo rpm --import https://rpm.packages.shiftkey.dev/gpg.key
                dnf install --nogpgcheck https://github.com/rpmsphere/noarch/raw/master/r/rpmsphere-release-40-1.noarch.rpm  -y -q
                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo sh -c 'echo -e "[shiftkey-packages]\nname=GitHub Desktop\nbaseurl=https://rpm.packages.shiftkey.dev/rpm/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://rpm.packages.shiftkey.dev/gpg.key" > /etc/yum.repos.d/shiftkey-packages.repo'
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
                dnf clean all
                dnf install rpmfusion-free-appstream-data -y -q
                dnf install rpmfusion-nonfree-appstream-data -y -q
                dnf install rpmfusion-free-release-tainted -y -q
                dnf install rpmfusion-nonfree-release-tainted -y -q
                sudo sh -c  'echo "[antigravity-rpm]
                name=Antigravity RPM Repository
                baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
                enabled=1
                gpgcheck=0" > /etc/yum.repos.d/antigravity.repo'
                dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
		        dnf config-manager --set-enabled google-chrome
                dnf makecache -q
                dnf check-update -q
                echo "Depot installer"
            fi
            exit 0
            ;;
        2)
            if [ "$EUID" -ne 0 ]; then
                echo "Cette fonction dois etre lancer en root ."
                echo "Veuillez réessayer avec: sudo $0"
                exit 1
            else 
                apps=$(grep -v '^#' app.txt | tr '\n' ' ')
                suppr=$(grep -v '^#' remove.txt | tr '\n' ' ')
                appflatpack=$(grep -v '^#' flapack.txt | tr '\n' ' ')
                dnf remove -y -q $suppr
                dnf update -y -q 
                dnf install -y -q $apps
                flatpak install flathub $appflatpack -y > /dev/null 2>&1
            fi 
            exit 0
            ;;
        3)
            echo "Mise en place des mise a jour"
            dnf update -y -q
            flatpak update -y > /dev/null 2>&1

            ;;
        4)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "Choix invalide. Veuillez entrer un nombre entre 1 et 4."
            ;;
    esac
    
    echo # Ligne vide pour la lisibilité
done