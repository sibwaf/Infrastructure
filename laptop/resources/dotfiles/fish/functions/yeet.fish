function yeet --wraps="pacman -Rscn" --description 'alias yeet "pacman -Rscn"'
  sudo pacman -Rscn $argv
end
