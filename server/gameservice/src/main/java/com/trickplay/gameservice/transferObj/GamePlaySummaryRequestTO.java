package com.trickplay.gameservice.transferObj;


public class GamePlaySummaryRequestTO {

	private String detail;


	public GamePlaySummaryRequestTO() {
		
	}
	
	public GamePlaySummaryRequestTO(String detail) {
		this.detail = detail;
	}


    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

}
