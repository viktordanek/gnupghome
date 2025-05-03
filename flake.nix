{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            shell-scripts.url = "github:viktordanek/shell-scripts/issue/git@github.com:viktordanek/gnupg.git" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , self , shell-scripts } :
            let
                fun =
                    system :
                        let
                            lib =
                                {
                                    gpg-ownertrust ,
                                    gpg2-ownertrust ,
                                    gpg-private-keys ,
                                    gpg2-private-keys ,
                                    lifespan ? 60 * 60 * 24 * 7 ,
                                } :
                                    let
                                        point =
                                            builtins.getAttr system shell-scripts.lib
                                                {
                                                    shell-scripts =
                                                        { cache , ... } :
                                                            {
                                                                init =
                                                                    {
                                                                        profile =
                                                                            { string , ... } :
                                                                                [
                                                                                    ( string "GPG" "${ pkgs.gnupg }/bin/gpg" )
                                                                                    ( string "GPG2" "${ pkgs.gnupg }/bin/gpg2" )
                                                                                    ( string "MKDIR" "${ pkgs.coreutils }/bin/mkdir" )
                                                                                ] ;
                                                                        script =
                                                                            ''
                                                                                export GNUPHOME=/mount/target &&
                                                                                    ${ _environment-variable "MKDIR" } ${ _environment-variable "GNUPGHOME" } &&
                                                                                    ${ _environment-variable "CHMOD" } 0700 ${ _environment-variable "GNUPHOME" } &&
                                                                                    ${ _environment-variable "GPG" } --batch --homedir ${ _environment-variable "GNUPGHOME" } --import ${ primary.gpg-secret-keys } &&
                                                                                    ${ _environment-variable "GPG" } --homedir ${ _environment-variable "GNUPGHOME" } --import-ownertrust ${ primary.gpg-ownertrust } &&
                                                                                    ${ _environment-variable "GPG2" } --homedir ${ _environment-variable "GNUPGHOME" } --import ${ primary.gpg2-secret-keys } &&
                                                                                    ${ _environment-variable "GPG2" } --homedir ${ _environment-variable "GNUPGHOME" } --import-ownertrust ${ primary.gpg2-ownertrust } &&
                                                                            '' ;
                                                                    } ;
                                                            } ;
                                                } ;
                                        in point.shell-scripts ;
                            in
                                {
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}