import trickplay.*;

class BootStrap {

    def passwordEncoder;

     def init = { servletContext ->

        def save = { it.save(); if (it.hasErrors()) { println it.errors } }

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
         def cat_featured = new Category(name:"Featured");
         cat1.save();
         cat2.save();
         cat3.save();
         cat4.save();
         cat5.save();
         cat_featured.save();

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
             
        // True Blood Comics
        

        def tb_icon = new Media(
                                imgType:"icon",
                                mimeType:"image/jpeg",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.trueblood/icon.jpg"));

        def tb_featured_icon = new Media(
                                imgType:"featuredIcon",
                                mimeType:"image/png",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.trueblood/featured.png"));
        
        def tb_background = new Media(
                                imgType:"background",
                                mimeType:"image/jpeg",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.trueblood/background.jpg"));
        
        
        save( tb_icon )
        save( tb_featured_icon )
        save( tb_background )
        
        def app1 = new Application(name:"True Blood Comics",
                                   appId:"com.hbo.TrueBlood",
                                    description:"View full screen art with new stories never seen before! Blood and sex mix on a hot rainy night at Merlotte's, when Sookie and her friends are trapped by a vengeful spirit who feeds on shame. Bon Temps, Louisiana has never been stranger, or more twisted, in a new story co-plotted by TRUE BLOOD series creator Alan Ball, with a script from David Tischman and Mariah Huehner, and lush art by David Messina.",
                                    supportEmail:"support@trickplay.com",
                                    license:"free for all",
                                    websiteUrl:new URL("http://hbo.com/"),
                                    icon:tb_icon,
                                    price:1.99,
                                    approved:true,
                                    developer:dev1,
                                    categories:[cat1,cat3,cat_featured],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[tb_featured_icon,tb_background])])]);
         save( app1 )

         
         def hulu_icon = new Media(
                                imgType:"icon",
                                mimeType:"image/jpeg",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.hulu/icon.jpg"));

         def hulu_featured_icon = new Media(
                                imgType:"featuredIcon",
                                mimeType:"image/png",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.hulu/featured.png"));
         
         def hulu_background = new Media(
                                imgType:"background",
                                mimeType:"image/jpeg",
                                mediaUrl:new URL("http://store.trickplay.com/v1/com.trickplay.fake.hulu/background.jpg"));
         
         
         save( hulu_icon );
         save( hulu_featured_icon );
         save( hulu_background );
         
         def app2 = new Application(name:"Hulu Plus",
                                   appId:"com.hulu.HuluPlus",
                                    description:"Choose from more than 2,600 current primetime TV hits such as The Simpsons, 30 Rock, Lost, Glee and The Office the morning after they air; classics like Buffy the Vampire Slayer, The A-Team, Airwolf and Married...with Children; movies like Last of the Mohicans and Basic Instinct; documentaries like Super Size Me, and other popular TV shows and movies.",
                                    supportEmail:"support@hulu.com",
                                    license:"None",
                                    websiteUrl:new URL("http://www.hulu.com/"),
                                    icon:hulu_icon,
                                    price:0.00,
                                    approved:true,
                                    developer:dev2,
                                    categories:[cat4,cat_featured],
                                    versions:[new Version(versionNumber:1,
                                                          freeUpdate:true,
                                                          current:true,
                                                          releases:[new Release(notes:"Launch",
                                                                                requirements:"",
                                                                                releaseNumber:1,
                                                                                approved:true,
                                                                                current:true,
                                                                                medias:[hulu_featured_icon,hulu_background])])]);
         save( app2 );

         
        def make_app = { name , tp_id , icon_url ->
            
            def icon = new Media( imgType:"icon", mimeType:"image/jpeg", mediaUrl:new URL(icon_url));
            
            save( icon );

            def app = new Application(name:name,
                                      appId:tp_id,
                                       description:"Lorem ipsum.",
                                       supportEmail:"support@trickplay.com",
                                       license:"GPL",
                                       websiteUrl:new URL("http://www.trickplay.com/"),
                                       icon:icon,
                                       price:0.99,
                                       approved:true,
                                       developer:dev2,
                                       categories:[cat1],
                                       versions:[new Version(versionNumber:1,
                                                             freeUpdate:true,
                                                             current:true,
                                                             releases:[new Release(notes:"Launch",
                                                                                   requirements:"",
                                                                                   releaseNumber:1,
                                                                                   approved:true,
                                                                                   current:true,
                                                                                   medias:[])])]);
            save( app );
        }
        
        make_app( "Cow Tipper" , "com.trickplay.Cow",  "http://store.trickplay.com/v1/com.trickplay.fake.cowtipper/icon.jpg" );
        make_app( "NBA" , "com.trickplay.NBA",  "http://store.trickplay.com/v1/com.trickplay.fake.nba/icon.jpg" );
        make_app( "HBO" , "com.trickplay.HBO",  "http://store.trickplay.com/v1/com.trickplay.fake.hbo/icon.jpg" );
        make_app( "Candyland" , "com.trickplay.Candyland",  "http://store.trickplay.com/v1/com.trickplay.fake.candyland/icon.jpg" );
        make_app( "Poker Dawgs" , "com.trickplay.Poker",  "http://store.trickplay.com/v1/com.trickplay.fake.pokerdawgs/icon.jpg" );
        make_app( "Plants vs. Zombies" , "com.trickplay.PlantsVZombies",  "http://store.trickplay.com/v1/com.trickplay.fake.pvz/icon.jpg" );
        make_app( "1945" , "com.trickplay.1945",  "http://store.trickplay.com/v1/com.trickplay.fake.1945/icon.jpg" );
        make_app( "8 Ball Billiards HD" , "com.trickplay.Billiards",  "http://store.trickplay.com/v1/com.trickplay.fake.billiards/icon.jpg" );
        make_app( "Solitaire" , "com.trickplay.Solitaire",  "http://store.trickplay.com/v1/com.trickplay.fake.solitaire/icon.jpg" );
        make_app( "NFL" , "com.trickplay.",  "http://store.trickplay.com/v1/com.trickplay.fake.nfl/icon.jpg" );
        make_app( "American Idol" , "com.trickplay.AmericanIdol",  "http://store.trickplay.com/v1/com.trickplay.fake.idol/icon.jpg" );
        make_app( "The Game of Life" , "com.trickplay.Life",  "http://store.trickplay.com/v1/com.trickplay.fake.life/icon.jpg" );
        make_app( "Spirals" , "com.trickplay.Spirals",  "http://store.trickplay.com/v1/com.trickplay.fake.spirals/icon.jpg" );
        make_app( "Aquaria" , "com.trickplay.Aquaria",  "http://store.trickplay.com/v1/com.trickplay.fake.aquaria/icon.jpg" );
        make_app( "Carlsberg" , "com.trickplay.Carlsberg",  "http://store.trickplay.com/v1/com.trickplay.fake.carlsberg/icon.jpg" );
         
     }

     def destroy = {
     }
} 
