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
namespace SpDj
{
    template<typename Key, typename Value>
    Store<Key, Value>::Record::Record(const Promise& p, bool u) : promise(p) {
	used = u;
    }

    template<typename Key, typename Value>
    template <typename T>
    Store<Key, Value>::Store(const T& f, long long timeout) {
	_loader = std::function<Promise (const Key&)>(f);
	_timeout = timeout;
	_watchTimeout();
    }

    template<typename Key, typename Value>
    Store<Key, Value>::~Store() {
	_timeoutEvent.cancel();
    }

    template<typename Key, typename Value>
    void Store<Key, Value>::_onTimeout() {
	auto it = _store.begin(), end = _store.end();
	std::list<decltype(it)> toDelete;

	while (it != end) {
	    if (it->second.used == false) {
		toDelete.push_back(it);
	    }
	    it->second.used = false;
	    ++it;
	}

	for (auto i : toDelete) {
	    _store.erase(i);
	}
	_watchTimeout();
    }


    template<typename Key, typename Value>
    void Store<Key, Value>::_watchTimeout() {
	if (_timeout != 0) {
	    _timeoutEvent = IOService::addTimer(_timeout, [this] () {
		_onTimeout();
	    });
	}
    }

    template<typename Key, typename Value>
    typename Store<Key, Value>::Promise Store<Key, Value>::get(const Key& key) {
	auto it = _store.find(key);
	if (it != _store.end())
	    return it->second.promise;

	auto promise =  _loader(key);
	_store.insert(std::make_pair(key, Record(promise, true)));
	return promise;
    }


}
