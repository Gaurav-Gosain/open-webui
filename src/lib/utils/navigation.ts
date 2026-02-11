import { goto as _goto } from '$app/navigation';
import { base } from '$app/paths';

export function goto(url: string, opts?: Parameters<typeof _goto>[1]) {
	if (url.startsWith('/')) {
		// Don't double-prefix if the URL already starts with the base path
		if (base && (url === base || url.startsWith(base + '/'))) {
			return _goto(url, opts);
		}
		return _goto(`${base}${url}`, opts);
	}
	return _goto(url, opts);
}
