#ifndef _GAME_H_
#define _GAME_H_

#include <vector>
#include "libgameservice.h"
#include "role.h"

namespace libgameservice {

typedef std::vector<Role> RoleVector;

class AppId {
public:
	AppId(const std::string &name, int version) :
		name_(name), version_(version) {
	}

	AppId() :
		version_(-1) {
	}

	AppId& operator= (const AppId& other) {
		name_ = other.name_;
		version_ = other.version_;
		return *this;
	}

	const std::string& name() const {
		return name_;
	}
	void set_name(const std::string& name) { name_ = name; }

	int version() const {
		return version_;
	}
	void set_version(int version) { version_ = version; }

	bool is_valid() const { return !name_.empty() && version_ > 0; }

	std::string Str() const { return std::string(name_) + ":" + intToString(version_); }

	std::string AsID() const { return "urn:xmpp:mug:tp:" + Str(); }

private:
	std::string name_;
	int version_;
};

class GameId {

public:
	GameId(const AppId& app_id, const std::string& name) : app_id_(app_id), name_(name) { }
	GameId() {}

	GameId& operator= (const GameId& other) {
		app_id_ = other.app_id_;
		name_ = other.name_;
		return *this;
	}

	static GameId parseGameId(const std::string& game_id_str);

	const AppId& app_id() const { return app_id_; }
	void set_app_id(const AppId& app_id) { app_id_ = app_id; }

	const std::string& name() const { return name_; }
	void set_name(const std::string& name) { name_ = name; }

	bool is_valid() const { return app_id_.is_valid() && !name_.empty(); }

	std::string Str() const { return app_id_.Str() + ":" + name_; }

	std::string AsID() const { return app_id_.AsID() + ":" + name_; }
private:
	AppId app_id_;
	std::string name_;
};

class Game {

public:
	enum TurnPolicy {
		roundrobin, simultaneous, specifiedRole
	};

	enum GameType {
		correspondence, online
	};

	static std::string game_type_to_string(GameType gt);
	static std::string turn_policy_to_string(TurnPolicy tp);

	static GameType game_type_from_string(const std::string& str);
	static TurnPolicy turn_policy_from_string(const std::string& str);

	Game() :
		turn_policy_(roundrobin), game_type_(correspondence),
		join_after_start_(true), min_players_for_start_(1), max_duration_per_turn_(0),
		abort_when_player_leaves_(false)
		{ }

	Game(const GameId& game_id) :
		game_id_(game_id), turn_policy_(roundrobin), game_type_(correspondence),
		join_after_start_(true), min_players_for_start_(1), max_duration_per_turn_(0),
		abort_when_player_leaves_(false)
	{ }

	const GameId& game_id() const { return game_id_; }
	void set_game_id(const GameId& game_id) { game_id_ = game_id; }

	const std::string& description() const {
		return description_;
	}
	void set_description(const std::string& description) {
		description_ = description;
	}

	const std::string& category() const {
		return category_;
	}
	void set_category(const std::string& category) {
		category_ = category;
	}

	TurnPolicy turn_policy() const {
		return turn_policy_;
	}
	void set_turn_policy(TurnPolicy policy) {
		turn_policy_ = policy;
	}

	GameType game_type() const {
		return game_type_;
	}
	void set_game_type(GameType gtype) {
		game_type_ = gtype;
	}

	bool join_after_start() const { return join_after_start_; }
	void set_join_after_start(bool join) { join_after_start_ = join; }

	int min_players_for_start() const { return min_players_for_start_; }
	void set_min_players_for_start(int min) { min_players_for_start_ = min; }

	long max_duration_per_turn() const { return max_duration_per_turn_; }
	void set_max_duration_per_turn(long max) { max_duration_per_turn_ = max; }

	bool abort_when_player_leaves() const { return abort_when_player_leaves_; }
	void set_abort_when_player_leaves(bool abort_flag) { abort_when_player_leaves_ = abort_flag; }

	RoleVector& roles() { return roles_; }
	void set_roles(RoleVector& nroles) {
		roles_ = nroles;
	}

private:
	GameId game_id_;
	std::string description_;
	std::string category_;
	TurnPolicy turn_policy_;
	GameType game_type_;
	bool join_after_start_;
    int min_players_for_start_;
    long max_duration_per_turn_;
    bool abort_when_player_leaves_;
    RoleVector roles_;
};

}
#endif /* _GAME_H_ */
