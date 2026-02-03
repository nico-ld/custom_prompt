#!/bin/zsh

# Activer les substitutions dans le prompt
setopt PROMPT_SUBST

# Couleurs personnalisées (tons clairs)
VIOLET='%F{141}'      # Violet clair
ORANGE='%F{208}'      # Orange clair
VIOLET_GIT='%F{129}'  # Violet pour Git
ROUGE='%F{196}'
VERT='%F{34}'
RESET='%f%k'
BOLD='%B'
NOBOLD='%b'

# Fonction pour obtenir le statut Git
git_prompt() {
    # Vérifier si on est dans un repo git
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local git_branch=""
        local git_status=""
        
        # Récupérer la branche
        git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || \
                 git describe --tags --exact-match 2>/dev/null || \
                 git rev-parse --short HEAD 2>/dev/null)
        
        # Vérifier s'il y a des modifications
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_status=" ●"
		fi
        
        echo " ${VIOLET_GIT}git:${BOLD}${git_branch}${git_status}${NOBOLD}${RESET}"
    fi
}

# Fonction pour gérer l'affichage du chemin
custom_path() {
    local path="$PWD"
    local home="$HOME"
    local display_path=""
    
    # Si on est dans le home, afficher l'icône maison
    if [[ "$path" == "$home" ]]; then
        echo "${ORANGE}🏠${RESET}"
        return
    fi
    
    # Remplacer le home par ~ dans le chemin
    if [[ "$path" == "$home"/* ]]; then
        path="~${path#$home}"
    fi
    
    # Diviser le chemin en segments
    local -a segments
    segments=("${(@s:/:)path}")
    local total_segments=${#segments[@]}
    local start_index=1
    local char_count=0
    local depth_count=0
    
    # Calculer à partir de quel segment commencer
    for ((i=1; i<=total_segments; i++)); do
        local segment="${segments[i]}"
        char_count=$((char_count + ${#segment} + 1))  # +1 pour le /
        depth_count=$((depth_count + 1))
        
        # Décaler si on dépasse 20 caractères OU 3 niveaux de profondeur
        if [[ $char_count -gt 20 ]] || [[ $depth_count -gt 3 ]]; then
            start_index=$i
            char_count=${#segment}
            depth_count=1
        fi
    done
    
    # Construire le chemin à afficher
    if [[ $start_index -gt 1 ]]; then
        display_path=".../"
    fi
    
    for ((i=start_index; i<=total_segments; i++)); do
        local segment="${segments[i]}"
        
        if [[ $i -eq 1 ]] && [[ "$segment" == "~" ]]; then
            display_path+="🏠"
        else
            if [[ -n "$segment" ]]; then
                display_path+="$segment"
            fi
        fi
        
        if [[ $i -lt $total_segments ]]; then
            display_path+="/"
        fi
    done
    
    echo "${ORANGE}${display_path}${RESET}"
}

# Construire le prompt
build_prompt() {
    PROMPT="$(custom_path)$(git_prompt) %(?.${VERT}.${ROUGE})❯${RESET} "
	RPROMPT="${ORANGE}%T${RESET}"
}

# Ajouter la fonction au précmd (équivalent de PROMPT_COMMAND en bash)
# Utiliser add-zsh-hook si disponible, sinon directement precmd
if (( $+functions[add-zsh-hook] )); then
    add-zsh-hook precmd build_prompt
else
    precmd() { build_prompt }
fi
