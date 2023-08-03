for f in $(find . -name "*.lua"); do
    if [ $(cat $f | grep logger | grep -v "^ *--" | wc -l) -gt 0 ]; then
        echo -e "Attention! There are loggers in the source code\n"
        read
    fi
done
VERSION="$(cat Tetris.txt  | grep "## Version:" | cut -d":" -f2 | xargs)"
rm Tetris*.zip
mkdir Tetris
cp Tetris.txt Tetris.lua Bindings.xml Preview.lua Moves.lua Tetris
7z a -r Tetris-$VERSION.zip Tetris
rm -rf Tetris