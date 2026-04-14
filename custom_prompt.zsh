#!/bin/zsh

# Enable prompt substitutions
setopt PROMPT_SUBST

# Custom colors
PURPLE='%F{141}'
ORANGE='%F{208}'
PURPLE_GIT='%F{129}'
RED='%F{196}'
BROWN='%F{130}'
GREEN='%F{34}'
RESET='%f%k'
BOLD='%B'
NOBOLD='%b'

# Variables for execution time tracking
typeset -g cmd_start_time
typeset -g cmd_exec_time

# Function called BEFORE command execution
preexec() {
	cmd_start_time=$(date +%s%3N) # Get time in milliseconds
}

# Format execution time for display
format_exec_time() {
	if [[ -n $cmd_exec_time ]] && [[ $cmd_exec_time -gt 0 ]]; then
		local time_ms=$cmd_exec_time
		local time_s=$((time_ms / 1000))
		local ms=$((time_ms % 1000))

		# More than one hour
		if (( time_s >= 3600 )); then
			local hours=$((time_s / 3600))
			local mins=$(((time_s % 3600) / 60))
			local secs=$((time_s % 60))
			echo "${BROWN}${hours}h${mins}m${secs}s${RESET}"
		# More than one minute
		elif (( time_s >= 60 )); then
			local mins=$(((time_s % 3600) / 60))
			local secs=$((time_s % 60))
			echo "${BROWN}${mins}m${secs}s${RESET}"
		# More than one second
		elif (( time_s >= 1 )); then
			local secs=$((time_s % 60))
			if (( ms < 10 )); then
				echo "${BROWN}${secs}.00${ms}s${RESET}"
			elif (( ms < 100 )); then
				echo "${BROWN}${secs}.0${ms}s${RESET}"
			else
				echo "${BROWN}${secs}.${ms}s${RESET}"
			fi
		# Less than one second
		else
			if (( ms < 10 )); then
				echo "${BROWN}0.00${ms}s${RESET}"
			elif (( ms < 100 )); then
				echo "${BROWN}0.0${ms}s${RESET}"
			else
				echo "${BROWN}0.${ms}s${RESET}"
			fi
		fi
	fi
}

# Function to get Git status
git_prompt() {
    # Check if we're in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local git_branch=""
        local git_status=""
        
        # Get the branch name
        git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || \
                 git describe --tags --exact-match 2>/dev/null || \
                 git rev-parse --short HEAD 2>/dev/null)
        
        # Check for uncommitted changes
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_status=" ●"
		fi
        
        echo " ${PURPLE_GIT}git:${BOLD}${git_branch}${git_status}${NOBOLD}${RESET}"
    fi
}

# Function to handle path display
custom_path() {
    local path="$PWD"
    local home="$HOME"
    local display_path=""
    
    # If we're in home display house icon
    if [[ "$path" == "$home" ]]; then
        echo "${ORANGE}🏠${RESET}"
        return
    fi
    
    # Remplace home with ~ in the path
    if [[ "$path" == "$home"/* ]]; then
        path="~${path#$home}"
    fi
    
    # Split the path into segments
    local -a segments
    segments=("${(@s:/:)path}")
    local total_segments=${#segments[@]}
    local start_index=1
    local char_count=0
    local depth_count=0
    
    # Calculate from wich segment to start displaying
    for ((i=1; i<=total_segments; i++)); do
        local segment="${segments[i]}"
        char_count=$((char_count + ${#segment} + 1))  # +1 for the /
        depth_count=$((depth_count + 1))
        
        # Shift if we exceed 20 characters OR 3 depth levels
        if [[ $char_count -gt 20 ]] || [[ $depth_count -gt 3 ]]; then
            start_index=$i
            char_count=${#segment}
            depth_count=1
        fi
    done
    
    # Build the path to display
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

# Build the prompt
build_prompt() {
	# Get last command code
	local error_code=$?

	# Calculate execution time if a command was run
	if [[ -n $cmd_start_time ]]; then
		local cmd_end_time=$(date +%s%3N)
		cmd_exec_time=$((cmd_end_time - cmd_start_time))
		unset cmd_start_time
	else
		cmd_exec_time=0
	fi

	# Main prompt: path, git status, green/red arrow based on exit code
    PROMPT="$(custom_path)$(git_prompt) %(?.${GREEN}.${RED}{${error_code}} )❯${RESET} "
	
	# Right prompt: execution time and current time
	RPROMPT="$(format_exec_time) ${ORANGE}%T${RESET}"
}

# Add the function to precmd (equivalent to PROMPT_COMMAND in bash)
# Use add-zsh-hook if avaible, otherwise use precmd directly
if (( $+functions[add-zsh-hook] )); then
    add-zsh-hook precmd build_prompt
else
    precmd() { build_prompt }
fi
