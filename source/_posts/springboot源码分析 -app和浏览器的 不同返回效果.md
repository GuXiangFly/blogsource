
---
title: springboot源码分析 -app和浏览器的 不同返回效果
date: 2017-3-11 23:09:04
tags: [Angular,前端]

---
为何springboot app访问不存在页面的时候返回的是 json字符串
而 浏览器访问的时候 返回的是一个 error试图
主要是由于
BasicErrorController 里面的以下代码
``` java
	@RequestMapping(produces = "text/html")
	public ModelAndView errorHtml(HttpServletRequest request,
			HttpServletResponse response) {
		HttpStatus status = getStatus(request);
		Map<String, Object> model = Collections.unmodifiableMap(getErrorAttributes(
				request, isIncludeStackTrace(request, MediaType.TEXT_HTML)));
		response.setStatus(status.value());
		ModelAndView modelAndView = resolveErrorView(request, response, status, model);
		return (modelAndView == null ? new ModelAndView("error", model) : modelAndView);
	}

	@RequestMapping
	@ResponseBody
	public ResponseEntity<Map<String, Object>> error(HttpServletRequest request) {
		Map<String, Object> body = getErrorAttributes(request,
				isIncludeStackTrace(request, MediaType.ALL));
		HttpStatus status = getStatus(request);
		return new ResponseEntity<Map<String, Object>>(body, status);
	}
```

浏览器访问时，请求头中的 content-Type会带有 "text/html" 这个参数，于是使用 上面的方法

我们常用来解决，同一个url 在某些情况下返回json 某些情况下返回html