/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
 *
 * Permission is hereby granted, free  of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,  including without limitation the rights
 * to use,  copy,  modify,  merge, publish,  distribute, sublicense, and/or sell
 * copies  of  the  Software,  and  to  permit  persons  to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The  above  copyright  notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY  OF ANY KIND, EXPRESS OR
 * IMPLIED,  INCLUDING BUT NOT LIMITED  TO THE  WARRANTIES  OF  MERCHANTABILITY,
 * FITNESS  FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR  ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT  OF  OR  IN  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <QNetworkReply>
#include <QUrl>
#include "HttpClient.h"


namespace SpDj
{
    HttpClient HttpClient::instance;

    When::Promise<std::string> HttpClient::get(const std::string& url) {
	auto defer = When::defer<std::string>();
QNetworkRequest request(QUrl(QString(url.c_str())));
	QNetworkReply* reply = instance._networkManager.get(request);
	connect(reply, &QNetworkReply::finished, &instance, &HttpClient::onFinished);
	instance._defers.insert(std::make_pair(reply, defer));
	return defer.promise();
    }

    void HttpClient::onFinished() {
	QNetworkReply* reply = dynamic_cast<QNetworkReply*>(sender());
	auto it = _defers.find(reply);
	if (it != _defers.end())
	    {
		auto defer = it->second;
		_defers.erase(it);
		if (reply->error() != QNetworkReply::NoError)
		    defer.reject("Can't get " + reply->request().url().toString().toStdString());
		else
		    defer.resolve(QString(reply->readAll()).toStdString());
	    }
	reply->deleteLater();
    }
}
