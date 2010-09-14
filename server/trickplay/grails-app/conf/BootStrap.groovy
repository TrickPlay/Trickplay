import trickplay.*;

class BootStrap {

    def passwordEncoder;

     def init = { servletContext ->
             //
         def role1 = new Role(authority:"ROLE_USER",
                              description:"User");
         role1.save();
         def role2 = new Role(authority:"ROLE_ADMIN",
                              description:"Admin");
         role2.save();
         def role3 = new Role(authority:"ROLE_DEVELOPER",
                              description:"Developer");
         role3.save();

         def user1 = new User(username:"garthpatil",
                              userRealName:"Garth Patil",
                              email:"garthpatil@gmail.com",
                              enabled:true,
                              passwd:passwordEncoder.encodePassword("lebowski", null));
         user1.save();
         if (user1.hasErrors()){
             println user1.errors
         }

         def userRole1 = new UserRole(user:user1,
                                      role:role1);
         userRole1.save();
         def userRole2 = new UserRole(user:user1,
                                      role:role2);
         userRole2.save();

         def user2 = new User(username:"craighughes",
                              userRealName:"Craig Hughes",
                              email:"craig@trickplay.com",
                              enabled:true,
                              passwd:passwordEncoder.encodePassword("lebowski", null));
         user2.save();
         if (user2.hasErrors()){
             println user2.errors
         }

         def userRole3 = new UserRole(user:user2,
                                      role:role1);
         userRole3.save();
         def userRole4 = new UserRole(user:user2,
                                      role:role2);
         userRole4.save();

         def device1 = new Device(deviceKey:"abc123",
                                  deviceType:"samsung 1080",
                                  owner:user1,
                                  provisioned:true);
         device1.save();
         if (device1.hasErrors()) {
             println device1.errors;
         }

         def cat1 = new Category(name:"Games");
         def cat2 = new Category(name:"Music");
         def cat3 = new Category(name:"Animation");
         def cat4 = new Category(name:"Photos");
         def cat5 = new Category(name:"Sports");
         def cat6 = new Category(name:"Featured");
         cat1.save();
         cat2.save();
         cat3.save();
         cat4.save();
         cat5.save();
         cat6.save();

         def vend1 = new Vendor(name:"Trickplay",
                                dateCreated:new Date(),
                                lastUpdated:new Date(),
                                approved:true);
         vend1.save();
         if (vend1.hasErrors()){
             println vend1.errors
         }

         def dev1 = new Developer(user:user1,
                                  vendor:vend1,
                                  dateCreated:new Date(),
                                  lastUpdated:new Date(),
                                  approved:true);
         dev1.save();
         if (dev1.hasErrors()){
             println dev1.errors
         }

         def dev2 = new Developer(user:user2,
                                  vendor:vend1,
                                  dateCreated:new Date(),
                                  lastUpdated:new Date(),
                                  approved:true);
         dev2.save();
         if (dev2.hasErrors()){
             println dev2.errors
         }

         def icon1 = new Media(imgType:"icon", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/049/Purple/54/7d/7b/mzl.btnqdaaq.175x175-75.jpg"));
         icon1.save();
          if (icon1.hasErrors()){
             println icon1.errors
         }
        def app1 = new Application(name:"Doodle Jump",
                                    description:"A clone of iPhone's wildly popular game.",
                                    supportEmail:"support@limasky.com",
                                    license:"free for all",
                                    websiteUrl:new URL("http://www.limasky.com/"),
                                    icon:icon1,
                                    price:1.99,
                                    approved:true,
                                    developer:dev1,
                                    categories:[cat1,cat3,cat6],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/041/Purple/5b/c4/38/mzl.wysngtfo.320x480-75.jpg")), new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/024/Purple/45/18/98/mzl.zepxrncb.320x480-75.jpg"))],
)])]);
         app1.save();
         if (app1.hasErrors()){
             println app1.errors
         }

         def icon2 = new Media(imgType:"icon", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/058/Purple/27/fb/29/mzl.mcpzyiba.175x175-75.jpg"));
         icon2.save();
         def app2 = new Application(name:"Flickr",
                                    description:"Awesome 3D way to view your Flickr photos.",
                                    supportEmail:"support@flickr.com",
                                    license:"Yahoo Public License",
                                    websiteUrl:new URL("http://www.flickr.com/"),
                                    icon:icon2,
                                    price:0.00,
                                    approved:true,
                                    developer:dev2,
                                    categories:[cat4],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/022/Purple/95/fd/bf/mzl.aalsvuwr.320x480-75.jpg")), new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/051/Purple/2e/8d/c7/mzl.xphvwcdf.320x480-75.jpg"))],
)])]);
         app2.save();
         if (app2.hasErrors()){
             println app2.errors
         }

         def icon3 = new Media(imgType:"icon", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/002/Purple/38/fc/0e/mzl.pstnvzug.175x175-75.jpg"));
         icon3.save();
         def app3 = new Application(name:"Yahoo Fantasy Football",
                                    description:"Yahoo! Fantasy Football, the Web’s #1 fantasy football game.",
                                    supportEmail:"support@yahoo.com",
                                    license:"Yahoo Public License",
                                    websiteUrl:new URL("http://www.yahoo.com/"),
                                    icon:icon3,
                                    price:7.99,
                                    approved:true,
                                    developer:dev2,
                                    categories:[cat5],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/021/Purple/e8/e9/e5/mzl.lsyyzuvw.320x480-75.jpg")), new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/027/Purple/36/98/0d/mzl.fschpcbs.320x480-75.jpg"))],
)])]);
         app3.save();
         if (app3.hasErrors()){
             println app3.errors
         }

         def icon4 = new Media(imgType:"icon", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/005/Purple/da/db/b3/mzl.sonzhhny.175x175-75.jpg"));
         icon4.save();
         def app4 = new Application(name:"Pandora Radio",
                                    description:"Pandora Radio is your own FREE personalized radio now available to stream music on your TV. Just start with the name of one of your favorite artists, songs or classical composers and Pandora will create a station that plays their music and more music like it.",
                                    supportEmail:"support@pandora.com",
                                    license:"Pandora EULA",
                                    websiteUrl:new URL("http://www.pandora.com/"),
                                    icon:icon4,
                                    price:0.00,
                                    approved:true,
                                    developer:dev1,
                                    categories:[cat2,cat6],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/036/Purple/95/6e/d8/mzl.beqctpjq.320x480-75.jpg")), new Media(imgType:"screenshot", mimeType:"image/jpeg", mediaUrl:new URL("http://a1.phobos.apple.com/us/r1000/051/Purple/db/41/92/mzl.pjrvhdfy.320x480-75.jpg"))],
)])]);
         app4.save();
         if (app4.hasErrors()){
             println app4.errors
         }
     }

     def destroy = {
     }
} 
