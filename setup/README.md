# Setup on Ubuntu



- Install packages (If you only intend to use the C++ version, you don't need the jdk). For Ubuntu:
    ```
    sudo apt-get install flex bison build-essential csh openjdk-6-jdk libxaw7-dev
    ```

- Make the /usr/class directory:
    ```
    sudo mkdir /usr/class/cool
    ```

- Make the directory owned by you:
    ```
    sudo chown $USER /usr/class/cool
    ```

- Copy tarball to `/usr/class`:
    ```
    mv cool.tar.gz /usr/class
    ```

- Untar:
    ```
    tar -xf cool.tar.gz
    ```

- Add the bin directory to your $PATH environment variable. If you are using bash, add to your .profile (or .bash_profile, etc. depending on your configuration; note that in Ubuntu have to log out and back in for this to take effect):
    ```
    PATH=/usr/class/cs143/cool/bin:$PATH
    ```