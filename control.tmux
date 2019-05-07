#!/usr/bin/env bash

default_pane_resize="5"

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z $option_value ]; then
		echo $default_value
	else
		echo $option_value
	fi
}

pane_navigation_bindings() {
	tmux bind-key -r h   select-pane -L
	tmux bind-key -r j   select-pane -D
	tmux bind-key -r k   select-pane -U
	tmux bind-key -r l   select-pane -R
}

window_move_bindings() {
	tmux bind-key -r "<" swap-window -t -1
	tmux bind-key -r ">" swap-window -t +1
}

pane_resizing_bindings() {
	local pane_resize=$(get_tmux_option "@pane_resize" "$default_pane_resize")
	tmux bind-key -r H resize-pane -L "$pane_resize"
	tmux bind-key -r J resize-pane -D "$pane_resize"
	tmux bind-key -r K resize-pane -U "$pane_resize"
	tmux bind-key -r L resize-pane -R "$pane_resize"
}

pane_split_bindings() {
	tmux bind-key "|" split-window -h -c "#{pane_current_path}"
	tmux bind-key "\\" split-window -fh -c "#{pane_current_path}"
	tmux bind-key "-" split-window -v -c "#{pane_current_path}"
	tmux bind-key "_" split-window -fv -c "#{pane_current_path}"
	tmux bind-key "%" split-window -h -c "#{pane_current_path}"
	tmux bind-key '"' split-window -v -c "#{pane_current_path}"
}

improve_new_window_binding() {
	tmux bind-key "c" new-window -c "#{pane_current_path}"
}

prefix_binding() {
    tmux unbind-key C-b
    tmux set -g prefix C-a
    tmux bind-key C-a send-prefix
}

edit_and_load_configuration_binding() {
    # edit configuration
    tmux bind-key e new-window -n '~/.tmux.conf.local' "sh -c '\${EDITOR:-vim} ~/.tmux.conf.local && tmux source ~/.tmux.conf && tmux display \"~/.tmux.conf sourced\"'"

    # reload configuration
    tmux bind-key r source-file ~/.tmux.conf \; display '~/.tmux.conf sourced'
}


navigation_binding() {
    # find session
    tmux bind-key C-f command-prompt -p find-session 'switch-client -t %%'

    # kill the session
    tmux bind-key -n F12 confirm kill-session
    # kill the pane
    tmux bind-key -n F10 kill-pane
    # kill the window
    tmux bind-key -n F11 confirm kill-window
}

main() {
    prefix_binding
    edit_and_load_configuration_binding
    navigation_binding
	pane_navigation_bindings
	window_move_bindings
	pane_resizing_bindings
	pane_split_bindings
	improve_new_window_binding
}
main
