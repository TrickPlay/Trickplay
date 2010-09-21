package trickplay;

import com.lucastex.grails.fileuploader.UFile;

class Media {

    static constraints = {
        //mediaFile();
        mediaUrl();
        imgType(blank:false, inList:["screenshot", "icon", "background", "preview", "featuredIcon"])
        mimeType(blank:true);
    }

    String mimeType = "image/jpeg"
    String imgType = "screenshot";
    URL mediaUrl;
    //UFile mediaFile;

    def getImgUrl() {
        //HACK this should lazy-load the media from the sourceUrl and generate
        //     the imgUrl. Right now it just uses the sourceUrl
        //return sourceUrl;
        //return mediaFile.publicUrl;
        return mediaUrl.toString();
    }

}
