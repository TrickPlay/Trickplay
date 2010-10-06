package trickplay;

import WsController;
import grails.converters.*;

class ApplicationController extends WsController {
    def scaffold = true;

    def authorizeNetService;

    def full = {
        if (params.id == null) {
            forward(action:"error", params:[http_status:403, error_string:"Application ID required."]);
        } else {
            def a = Application.get(params.id);
            if (a != null) {
                render(contentType:'application/json') {
                    stat = "ok"
                    application (name:a.name,
                                 tp_id:a.appId,
                                 description:a.description,
                                 icon:a.icon.imgUrl,
                                 url:a.websiteUrl,
                                 email:a.supportEmail,
                                 license:a.license,
                                 price:a.price,
                                 vendor:a.developer.vendor.name,
                                 categories: array {
                                     for(c in a.categories) {
                                         category (name:c.name)
                                     }
                                 },
                                 medias: array {
                                     for(s in a.medias) {
                                         media (url:s.imgUrl, imageType:s.imgType, mimeType:s.mimeType)
                                     }
                                 },
                                 releases: array {
                                     for(v in a.versions) {
                                         for(r in v.releases) {
                                             if ((v.current && r.current) || params.dev) {
                                                 release (notes:r.notes, requirements:r.requirements, version:v.versionNumber, release:r.releaseNumber, current:r.current, update:r.autoUpdate)
                                             }
                                         }
                                     }
                                 })
                }
            } else {
                forward(action:"error", params:[http_status:404, error_string:"No application with id ${params.id} found."]);
            }
        }
    }
            
    def reviews = {
        if (params.id == null) {
            forward(action:"error", params:[http_status:403, error_string:"Application ID required."]);
        } else {
            def app = Application.get(params.id);
            if (app == null) {
                forward(action:"error", params:[http_status:404, error_string:"No application with id ${params.id} found."]);
            } else {
                def rs = Review.findAllByApplication(app);
                if (rs == null || rs.isEmpty()) {
                    forward(action:"error", params:[http_status:404, error_string:"No reviews found for application ${params.id}."]);
                } else {
                    // render
                    def result = [stat:"ok"];
                    reviews = []
                    for(r in rs) {
                        def user = [ id:r.user.id,
                            username:r.user.username,
                            email:r.user.email,
                            realname:r.user.userRealName ];
                        def review = [ application:r.application.id,
                            user:user,
                            stars:r.stars,
                            comment:r.comment,
                            date:r.dateCreated ];
                        reviews.add(review);
                    }
                    result.put("reviews", reviews);
                    render result as JSON;
                }
            }
        }
    }

    def search = {
        if(!params.max) params.max = "10";
        if(!params.offset) params.offset = "0";
        if(!params.sort) params.sort = "name";
        if(!params.order) params.order = "desc";
        try {
            // TODO: make this a query, rather than iterating through all apps
            def list = Application.list(sort:params.sort, order:params.order);
            def apps = [];
            for(a in list) {
                if (params.keyword) {
                    if (params.category) {
                        if (filterKeyword(a, params.keyword) && filterCategory(a, params.category)) apps.add(a);
                    } else {
                        if (filterKeyword(a, params.keyword)) apps.add(a);
                    }
                } else {
                    if (params.category) {
                        if(filterCategory(a, params.category)) apps.add(a);
                    } else {
                        apps.add(a);
                    }
                }
            }

            def apps2 = [];
            def off = 0;
            def added = 0;
            int offs = Integer.parseInt(params.offset);
            int maxs = Integer.parseInt(params.max);
            for (a in apps) {
                if (offs > off || added >= maxs) {
                    //no add
                } else {
                    apps2.add(a);
                    added++;
                }
                off++;
            }

            render(contentType:'application/json') {
                stat = "ok";
                results = apps2.size()
                total = apps.size()
                offset = offs
                sort = params.sort
                order = params.order
                applications = array {
                    for(a in apps2) {
                        application (id:a.id,
                                     tp_id:a.appId,
                                     name:a.name,
                                     description:a.description,
                                     icon:a.icon.imgUrl,
                                     url:a.websiteUrl,
                                     email:a.supportEmail,
                                     license:a.license,
                                     price:a.price,
                                     vendor:a.developer.vendor.name,
                                     medias: array {
                                         for(s in a.medias) {
                                             media (url:s.imgUrl, imageType:s.imgType, mimeType:s.mimeType)
                                         }
                                     },
                                     )
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            forward(action:"error", params:[http_status:400, error_string:"Problem executing search."]);
        }
    }

    def filterKeyword(Application a, String keywordList)
    {
        String[] kws = keywordList.split(",");
        boolean hasKeyword = false;
        for(String kw:kws) {
            if (a.name.toLowerCase().contains(kw.toLowerCase()) || a.description.toLowerCase().contains(kw.toLowerCase())) {
                hasKeyword = true;
            } else {
                return false;
            }
        }
        return hasKeyword;
    }

    def filterCategory(Application a, String categoryList)
    {
        String[] cs = categoryList.split(",");
        for(String c:cs) {
            boolean hasCategory = false;
            for(Category cat:a.categories) {
                if (cat.name.toLowerCase().equals(c.toLowerCase())) {
                    hasCategory = true;
                }
            }
            if (!hasCategory) {
                return false;
            }
        }
        return true;
    }

    def purchase = {
        //validate input
        //        
        SessionKey sessionKey = SessionKey.findByToken(params.token);
        Application application = Application.get(params.id);
        PaymentProfile pp = null;
        if (params.payment_profile != null) {
            pp = PaymentProfile.findByUserAndId(sessionKey.user, params.payment_profile);
            if (!pp.enabled) pp = null;
        }
        if (pp == null) {
            if (params.cc_no != null && params.cc_exp != null && params.cc_cvv2 != null) {
                pp = authorizeNetService.newPaymentProfile(sessionKey.user, params.cc_no, params.cc_exp, params.cc_cvv2);
            } else {
                // throw an error
            }
        }
        def purchase = authorizeNetService.makePurchase(sessionKey.user, pp, params.cc_cvv2, application);
        if (params.cc_save != null && params.cc_save.equals("false")) {
            //disable this payment profile
            pp.enabled = false;
            pp.save();
        }
    }
    
}
