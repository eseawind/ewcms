/**
 * Copyright (c)2010-2011 Enterprise Website Content Management System(EWCMS), All rights reserved.
 * EWCMS PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * http://www.ewcms.com
 */

package com.ewcms.publication.freemarker.html;

import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.Assert;

import com.ewcms.core.site.model.Channel;
import com.ewcms.core.site.model.Site;
import com.ewcms.core.site.model.Template;
import com.ewcms.publication.PublishException;
import com.ewcms.publication.freemarker.GlobalVariable;
import com.ewcms.publication.output.OutputResource;
import com.ewcms.publication.service.ArticlePublishServiceable;
import com.ewcms.publication.uri.DefaultHomeUriRule;
import com.ewcms.publication.uri.DefaultListUriRule;
import com.ewcms.publication.uri.NullUriRule;
import com.ewcms.publication.uri.UriRuleable;

import freemarker.template.Configuration;

/**
 * 生成频道文章列表页
 * 
 * @author wangwei
 */
public class ListGenerator extends GeneratorBase {
    
    private static final Logger logger = LoggerFactory.getLogger(ListGenerator.class);
    
    private static final UriRuleable DEFAULT_URI_RULE = new DefaultListUriRule();
    private static final UriRuleable DEFAULT_HOME_URI_RULE = new DefaultHomeUriRule();
    
    private Configuration cfg;
    private ArticlePublishServiceable service;
    private boolean createHome;
    
    public ListGenerator(Configuration cfg,ArticlePublishServiceable service,boolean createHome){
        Assert.notNull(cfg);
        Assert.notNull(service);
        Assert.notNull(createHome);
        
        this.cfg = cfg;
        this.service = service;
        this.createHome = createHome;
    }
    
    /**
     * 构造生成页面参数集合
     * 
     * @param site
     *          站点对象
     * @param channel
     *          频道对象
     * @param pageNumber
     *          页数
     * @param pageCount
     *          页数总合
     * @param debug
     *          是否调试
     * @return
     */
    private Map<String,Object> constructParameters(Site site,Channel channel,
            Integer pageNumber,Integer pageCount,Boolean debug) {
        
        Map<String,Object> params = new HashMap<String,Object>();
        params.put(GlobalVariable.SITE.toString(), site);
        params.put(GlobalVariable.CHANNEL.toString(), channel);
        params.put(GlobalVariable.PAGE_NUMBER.toString(), pageNumber);
        params.put(GlobalVariable.PAGE_COUNT.toString(), pageCount);
        params.put(GlobalVariable.DEBUG.toString(), debug);
        
        return params;
    }

    private Integer getPageCount(Channel channel){
        Integer count = service.getArticleCount(channel.getId());
        logger.debug("Article count is {}",count);
        Integer row = channel.getListSize();
        
        return (count + row -1)/row;
    }
    
    
    @Override
    public List<OutputResource> process(Site site,Channel channel,Template template)throws PublishException {
        List<OutputResource> resources = new ArrayList<OutputResource>();
        freemarker.template.Template t = getFreemarkerTemplate(cfg,template.getUniquePath());
        Integer pageCount = getPageCount(channel);
        logger.debug("Page count is {}",pageCount);
        
        UriRuleable rule = getUriRule(template.getUriPattern(),DEFAULT_URI_RULE);
        
        if(createHome){
        	Map<String,Object> parameters = constructParameters(site,channel,0,pageCount,Boolean.FALSE);
        	OutputResource resource = generator(t,parameters,rule,DEFAULT_HOME_URI_RULE);
        	resources.add(resource);
        }
        
        for(int i = 0 ; i < pageCount; ++i){
            Map<String,Object> parameters = constructParameters(site,channel,i,pageCount,Boolean.FALSE);
            OutputResource resource = generator(t,parameters,rule);
            resources.add(resource);
        }
        
        return resources;
    }
    
    @Override
    public void previewProcess(OutputStream stream, Site site, Channel channel,Template template) throws PublishException {
        Map<String,Object> parameters = constructParameters(site,channel,1,20,Boolean.TRUE);
        freemarker.template.Template t = getFreemarkerTemplate(cfg,template.getUniquePath());
        UriRuleable rule =new NullUriRule();
        Writer writer = new OutputStreamWriter(stream);
        write(t , parameters, rule, writer);
    }
}
