#include <iostream>
#include <sstream>
#include <string>
#include "libgameservice.h"

namespace libgameservice {

std::string intToString(int val) {
	std::stringstream ss;
	ss << val;
	std::string valstr;
	ss >> valstr;
	return valstr;
}

std::string longToString(long val) {
	std::stringstream ss;
	ss << val;
	std::string valstr;
	ss >> valstr;
	return valstr;
}

std::string booleanToString(bool val) {
	std::stringstream ss;
	ss << std::boolalpha << val;
	std::string valstr;
	ss >> valstr;
	return valstr;
}

static const char* kStatusCodeStrings[] = {
	"OK",
	"FAILED",
	"LOGIN_FAILED",
	"NOT_CONNECTED",
	"APP_OPEN",
	"APP_ALREADY_OPEN",
	"APP_NOT_OPEN",
	"INVALID_GAME_ID",
	"INVALID_APP_ID",
	"INVALID_ROLE",
	"INVALID_MATCH_REQUEST",
};

const char* statusToString(StatusCode sc) {
	return kStatusCodeStrings[sc];
}

static const std::string ownerAffiliation("owner");
static const std::string memberAffiliation("member");
static const std::string noneAffiliation("none");
const std::string& affiliationToString(Affiliation affiliation) {
	switch (affiliation) {
			case owner:
				return ownerAffiliation;
			case member:
				return memberAffiliation;
			default:
				return noneAffiliation;
			}
}

Affiliation stringToAffiliation(const std::string& str) {
	if (ownerAffiliation == str)
		return owner;
	else if (memberAffiliation == str)
		return member;
	else
		return none;
}

//enum MatchStatus { created, active, paused, inactive, completed, aborted };
static const std::string createdStatus("created");
static const std::string activeStatus("active");
static const std::string pausedStatus("paused");
static const std::string inactiveStatus("inactive");
static const std::string completedStatus("completed");
static const std::string abortedStatus("aborted");
static const std::string unknownStatus("??");

const std::string& matchStatusToString(MatchStatus status) {
	switch (status) {
	case created:
		return createdStatus;
	case active:
		return activeStatus;
	case paused:
		return pausedStatus;
	case inactive:
		return inactiveStatus;
	case completed:
		return completedStatus;
	case aborted:
		return abortedStatus;
	}
	return unknownStatus;
}

MatchStatus stringToMatchStatus(const std::string& str) {
	if (createdStatus == str)
		return created;
	else if (activeStatus == str)
		return active;
	else if (pausedStatus == str)
		return paused;
	else if (inactiveStatus == str)
		return inactive;
	else if (completedStatus == str)
		return completed;
	else if (abortedStatus == str)
		return aborted;

	return unknown;
}

}
