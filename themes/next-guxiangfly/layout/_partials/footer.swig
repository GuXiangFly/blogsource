<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; &nbsp; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}
  </span>
  <span class="with-love">
    <i class="icon-next-heart"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}
  </span>
</div>

<div class="powered-by">
  Powered by <a class="theme-link" href="http://hexo.io">Hexo</a>
</div>

<div class="theme-info">
  Theme by <a class="theme-link" href="http://blog.guxiangfly.cn">guxiangfly</a>.<a class="theme-link" href="https://github.com/GuXiangFly/next-guxiangfly">next-guxiangfly</a>
</div>

<div class="BbeiAn-info">
	<a target="_blank" href="https://beian.miit.gov.cn/" style="color:#f0d784;text-decoration:none;padding-left:30px;background:url(https://s1.ax1x.com/2018/09/29/ilmwIH.png) no-repeat left center" rel="nofollow">{{ __('苏ICP备17066242号') }}</a>	  <!--这里将图标作为了背景，以使得能和后面的文字在同一行-->
</div>

<!-- busuanzi -->
{% if (theme.busuanzi) %}
  <div class="busuanzi-info">
    {% include '../_scripts/analytics/busuanzi.swig' %}
  </div>
{% endif %}

{% block footer %}{% endblock %}
