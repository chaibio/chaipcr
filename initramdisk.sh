
rm -rf .tmp web/public/javascripts web/public/stylesheets web/public/fonts web/public/images

mkdir .tmp web/public/javascripts web/public/stylesheets web/public/fonts web/public/images

mount -t tmpfs -o size=128m tmpfs .tmp
mount -t tmpfs -o size=128m tmpfs web/public/javascripts
mount -t tmpfs -o size=128m tmpfs web/public/stylesheets
mount -t tmpfs -o size=128m tmpfs web/public/fonts
mount -t tmpfs -o size=128m tmpfs web/public/images

chown $USER .tmp web/public/javascripts web/public/stylesheets web/public/fonts web/public/images

