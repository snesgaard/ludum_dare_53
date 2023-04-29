love_url=https://bitbucket.org/rude/love/downloads/love-11.3-x86_64.AppImage
love_bin=./love-11.3-x86_64.AppImage
love_game=./game.zip

play: $(love_bin)
	$(love_bin) $(love_game)

$(love_bin):
	wget $(love_url)
	chmod +x $@
