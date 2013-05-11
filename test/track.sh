#!/bin/bash

function setUp() {
	$HOMESHICK_BIN --batch clone $REPO_FIXTURES/rc-files > /dev/null
}

function testSimpleTrackingAbsolute() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_BIN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testSimpleTrackingRelative() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	(cd $HOME; $HOMESHICK_BIN track rc-files .zshrc) > /dev/null
	assertTrue "\`track' did not move the .zshrc file" "[ -f $HOMESICK/repos/rc-files/home/.zshrc ]"
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
}

function testNTrackingOverwrite() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_BIN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	rm $HOME/.zshrc
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh 7
EOF
	$HOMESHICK_BIN track rc-files $HOME/.zshrc &> /dev/null
	local tracked_file_size=$(stat -c %s $HOMESICK/repos/rc-files/home/.zshrc)
	assertTrue "\`track' has overwritten the previously tracked .zshrc file" "[ $tracked_file_size -eq 26 ]"
	assertTrue "\`track' has overwritten the new .zshrc file" "[ ! -L $HOME/.zshrc ]"
}

function testNDoubleTracking() {
	cat > $HOME/.zshrc <<EOF
homeshick --batch refresh
EOF
	$HOMESHICK_BIN track rc-files $HOME/.zshrc > /dev/null
	assertTrue "\`track' did not symlink the .zshrc file" "[ -L $HOME/.zshrc ]"
	$HOMESHICK_BIN track rc-files $HOME/.zshrc &> /dev/null
	assertTrue "\`track' has double tracked the .zshrc file" "[ ! -L $HOMESICK/repos/rc-files/home/.zshrc ]"
}

function tearDown() {
	rm -rf "$HOMESICK/repos/rc-files"
	find "$HOME" -mindepth 1 -not -path "${HOMESICK}*" -delete
}

source $SHUNIT2
