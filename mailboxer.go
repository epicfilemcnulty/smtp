// mailboxer is a dead simple MDA, kinda like procmail, stripped down
// to the core functionality -- read a message from STDIN
// and save it in user's maildir.
package main

import (
	"github.com/amalfra/maildir"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

func main() {
	var data []byte
	var err error
	args := os.Args[1:]
	if len(args) < 1 {
		log.Fatal("Not enough args")
	}
	basedir := os.Getenv("MAILDIR_BASE")
	if basedir == "" {
		basedir = "/data/mail"
	}
	email := strings.Split(args[0], "@")
	user, domain := email[0], email[1]
	md := maildir.NewMaildir(basedir + "/" + domain + "/" + user + "/Maildir")
	data, err = ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal("Failed to read stdin")
	} else {
		_, err = md.Add(string(data[:]))
		if err != nil {
			log.Fatal("Failed to save message")
		}
	}
}
