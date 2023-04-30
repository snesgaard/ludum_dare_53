title=fantasy_retail_simulator

linux_binary=build/$(title)_linux.zip
windows_zip=build/$(title)_win64.zip
windows_binary=build/$(title)_win64.exe

love_linux_app=build/love-11.4-x86_64.AppImage
love_win64_zip=build/love-11.4-win64.zip
love_win64=build/love-11.4-win64

love_file=build/game.zip

all: $(love_file) download $(linux_binary) $(windows_binary) $(windows_zip)

download: $(love_linux_app) $(love_win64_zip)

build:
	make -C src build

clean:
	rm -rf build
	make -C src/art clean

play:
	make -C src play

release:
	rm -f $(title).love
	rm -rf $(title)
	rm -f $(title).zip

	cp -r release_scripts $(title)
	mv $(title).love $(title)
	zip -9 -r $(title).zip $(title)

$(linux_binary): $(love_file) $(love_linux_app)
	@mkdir -p build/linux/$(title)
	cp $(love_file) build/linux/$(title)
	cp release_scripts/* build/linux/$(title)
	cp $(love_linux_app) build/linux/$(title)
	cd build/linux/; zip -9 -r tmp.zip $(title)
	mv build/linux/tmp.zip $@

$(love_linux_app):
	@mkdir -p $(dir $@)
	wget https://github.com/love2d/love/releases/download/11.4/love-11.4-x86_64.AppImage -O $@
	chmod +x $@

$(windows_binary): $(love_win64) $(love_file)
	cat $</love.exe $(love_file) > $@

$(windows_zip): $(love_win64) $(windows_binary)
	mkdir -p build/win64
	cp -r $(love_win64) build/win64/$(title)
	cp $(windows_binary) build/win64/$(title)
	rm build/win64/$(title)/love.exe build/win64/$(title)/lovec.exe
	cd build/win64/; zip -9 -r tmp.zip $(title)
	mv build/win64/tmp.zip $@

$(love_win64_zip):
	@mkdir -p $(dir $@)
	wget https://github.com/love2d/love/releases/download/11.4/love-11.4-win64.zip -O $@

$(love_win64): $(love_win64_zip)
	cd build; unzip love-11.4-win64.zip

$(love_file): build
	@mkdir -p $(dir $@)
	cd src; zip -9 -r ../$@ .

.PHONY: build
