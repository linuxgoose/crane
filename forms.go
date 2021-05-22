package main

import (
	"html"
	"net/http"
	"net/url"

	"github.com/microcosm-cc/bluemonday"
)

type FormValues map[string][]string

func FormHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		_, _ = w.Write([]byte("<html lang=en><meta charset=utf-8><meta content='width=device-width,initial-scale=1'name=viewport><head><link rel='shortcut icon' href='https://jordansukenik.com/content/images/size/w750/2021/05/crane-traced.png'></head><title>Crane is running</title><style>.body{padding-top:0;background-color:#fff}.main-text{text-align:center;margin:auto;padding:45px}.main-section{display:flex;flex-direction:column;min-height:97vh!important}.footer{display:flex;font-size:14px;width:100%;border-top:solid 1px #e5e8ed;display:block}.footer-item{margin:auto;text-align:center;font-weight:500;margin-bottom:10px;margin-top:10px}h1{margin-top:0;font-size:40px}body{font:20px Helvetica,sans-serif;color:#333}article{display:block;text-align:center;margin:0 auto}a{color:#333;text-decoration:none}@media (max-width:629px){.footer{display:block!important}.footer-item{padding-top:5px;padding-bottom:5px}}</style><body class=body><section class=main-section><div class=main-text><img src='https://jordansukenik.com/content/images/size/w750/2021/05/crane-traced.png' width=200><div><p>Crane email service is running! :)</div></div><div class=footer><div class=footer-item>Developed by Linuxgoose</div></div></section>"))
		return
	}
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_, _ = w.Write([]byte("The HTTP method is not allowed, make a POST request to use Crane."))
		return
	}
	_ = r.ParseForm()
	sanitizedForm := sanitizeForm(&r.PostForm)
	go func() {
		if checkToken(sanitizedForm) && !isBot(sanitizedForm) {
			sendForm(sanitizedForm)
		}
	}()
	sendResponse(sanitizedForm, w)
	return
}

func sanitizeForm(values *url.Values) *FormValues {
	p := bluemonday.StrictPolicy()
	sanitizedForm := make(FormValues)
	for key, values := range *values {
		var sanitizedValues []string
		for _, value := range values {
			sanitizedValues = append(sanitizedValues, html.UnescapeString(p.Sanitize(value)))
		}
		sanitizedForm[html.UnescapeString(p.Sanitize(key))] = sanitizedValues
	}
	return &sanitizedForm
}

func checkToken(values *FormValues) bool {
	if token := appConfig.Token; token != "" && (*values)["_token"][0] != token {
		return false
	}
	return true
}

func isBot(values *FormValues) bool {
	for _, honeyPot := range appConfig.HoneyPots {
		if len((*values)[honeyPot]) > 0 {
			for _, value := range (*values)[honeyPot] {
				if value != "" {
					return true
				}
			}
		}
	}
	return checkValues(values)
}

func sendResponse(values *FormValues, w http.ResponseWriter) {
	if len((*values)["_redirectTo"]) == 1 && (*values)["_redirectTo"][0] != "" {
		w.Header().Add("Location", (*values)["_redirectTo"][0])
		w.WriteHeader(http.StatusSeeOther)
		_, _ = w.Write([]byte("Go to " + (*values)["_redirectTo"][0]))
		return
	} else {
		w.WriteHeader(http.StatusCreated)
		_, _ = w.Write([]byte("Submitted form"))
		return
	}
}
