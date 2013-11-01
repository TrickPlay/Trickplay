#ifndef _STATUS_H_
#define _STATUS_H_

#include <string>

namespace libgameservice {

class GameStatus {
public:
  GameStatus()
      : pri_(0),
        show_(SHOW_NONE),
        available_(false),
        e_code_(0),
        feedback_probation_(false),
        know_capabilities_(false),
        voice_capability_(false),
        pmuc_capability_(false),
        video_capability_(false),
        camera_capability_(false) {
  }

  ~GameStatus() {}

  // These are arranged in "priority order", i.e., if we see
  // two statuses at the same priority but with different Shows,
  // we will show the one with the highest show in the following
  // order.
  enum Show {
    SHOW_NONE     = 0,
    SHOW_OFFLINE  = 1,
    SHOW_XA       = 2,
    SHOW_AWAY     = 3,
    SHOW_DND      = 4,
    SHOW_ONLINE   = 5,
    SHOW_CHAT     = 6,
  };

  const std::string& jid() const { return jid_str_; }
  int priority() const { return pri_; }
  Show show() const { return show_; }
  const std::string& status() const { return status_; }
  const std::string& nick() const { return nick_; }
  bool available() const { return available_ ; }
  int error_code() const { return e_code_; }
  const std::string& error_string() const { return e_str_; }
  bool know_capabilities() const { return know_capabilities_; }
  bool voice_capability() const { return voice_capability_; }
  bool pmuc_capability() const { return pmuc_capability_; }
  bool video_capability() const { return video_capability_; }
  bool camera_capability() const { return camera_capability_; }
  const std::string& caps_node() const { return caps_node_; }
  const std::string& version() const { return version_; }
  bool feedback_probation() const { return feedback_probation_; }
  const std::string& sent_time() const { return sent_time_; }

  void set_jid(const std::string& jid) { jid_str_ = jid; }
  void set_priority(int pri) { pri_ = pri; }
  void set_show(Show show) { show_ = show; }
  void set_status(const std::string& status) { status_ = status; }
  void set_nick(const std::string& nick) { nick_ = nick; }
  void set_available(bool a) { available_ = a; }
  void set_error(int e_code, const std::string e_str)
      { e_code_ = e_code; e_str_ = e_str; }
  void set_know_capabilities(bool f) { know_capabilities_ = f; }
  void set_voice_capability(bool f) { voice_capability_ = f; }
  void set_pmuc_capability(bool f) { pmuc_capability_ = f; }
  void set_video_capability(bool f) { video_capability_ = f; }
  void set_camera_capability(bool f) { camera_capability_ = f; }
  void set_caps_node(const std::string& f) { caps_node_ = f; }
  void set_version(const std::string& v) { version_ = v; }
  void set_feedback_probation(bool f) { feedback_probation_ = f; }
  void set_sent_time(const std::string& time) { sent_time_ = time; }

  void UpdateWith(const GameStatus& new_value) {
    if (!new_value.know_capabilities()) {
       bool k = know_capabilities();
       bool p = voice_capability();
       std::string node = caps_node();
       std::string v = version();

       *this = new_value;

       set_know_capabilities(k);
       set_caps_node(node);
       set_voice_capability(p);
       set_version(v);
    }
    else {
      *this = new_value;
    }
  }

  bool HasQuietStatus() const {
    if (status_.empty())
      return false;
    return !(QuietStatus().empty());
  }

  // Knowledge of other clients' silly automatic status strings -
  // Don't show these.
  std::string QuietStatus() const;

  std::string ExplicitStatus() const {
    std::string result = QuietStatus();
    if (result.empty()) {
      result = ShowStatus();
    }
    return result;
  }

  std::string ShowStatus() const {
    std::string result;
    if (!available()) {
      result = "Offline";
    }
    else {
      switch (show()) {
        case SHOW_AWAY:
        case SHOW_XA:
          result = "Idle";
          break;
        case SHOW_DND:
          result = "Busy";
          break;
        case SHOW_CHAT:
          result = "Chatty";
          break;
        default:
          result = "Available";
          break;
      }
    }
    return result;
  }

  static std::string TrimStatus(const std::string& st) {
    std::string s(st);
    int j = 0;
    bool collapsing = true;
    for (unsigned int i = 0; i < s.length(); i+= 1) {
      if (s[i] <= ' ' && s[i] >= 0) {
        if (collapsing) {
          continue;
        }
        else {
          s[j] = ' ';
          j += 1;
          collapsing = true;
        }
      }
      else {
        s[j] = s[i];
        j += 1;
        collapsing = false;
      }
    }
    if (collapsing && j > 0) {
      j -= 1;
    }
    s.erase(j, s.length());
    return s;
  }

private:
  std::string jid_str_;
  int pri_;
  Show show_;
  std::string status_;
  std::string nick_;
  bool available_;
  int e_code_;
  std::string e_str_;
  bool feedback_probation_;

  // capabilities (valid only if know_capabilities_
  bool know_capabilities_;
  bool voice_capability_;
  bool pmuc_capability_;
  bool video_capability_;
  bool camera_capability_;
  std::string caps_node_;
  std::string version_;

  std::string sent_time_; // from the jabber:x:delay element
};

class MucStatus : public GameStatus {
};

}


#endif
