karafka_config = Rails.application.config_for(:karafka)

KARAFKA_BROKER = karafka_config[:host]
KARAFKA_CLIENT_ID = karafka_config[:client_id]

CREATE_CHAT_TOPIC = karafka_config[:create_chat_topic]
CREATE_MSG_TOPIC = karafka_config[:create_msg_topic]
