# Compile and install zsh from source, useful when no sudo permission on
# a server.

# Install ncurse.
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz --no-check-certificate
tar xvfz ncurses-6.1.tar.gz
cd ncurses-6.1
./configure --prefix="$HOME/bin" CXXFLAGS="-fPIC" CFLAGS="-fPIC"
make && make install

# Install zsh.
wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download --no-check-certificate
tar xvf zsh.tar.xz
cd zsh # This will probably need to change to match the version.
./configure --prefix="$HOME/bin" CPPFLAGS="-I$HOME/bin/include" LDFLAGS="-L$HOME/bin/lib"
make && make install

# Then, run source ~/.bashrc
