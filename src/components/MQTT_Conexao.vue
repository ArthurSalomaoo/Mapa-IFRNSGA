
/*
  Esse arquivo se conecta com o broker e recebe as mensagens do mesmo e exibe as informações da sala
*/

<template>
  <div id="div-info" v-if="modal">
    <h2>Número da sala: {{ numero_sala_clicada }}</h2>
    <p>Temperatura da sala: {{ sala_temp }}</p>
    <p>Luz: {{ sala_luz }}</p>
    <p>Tem pessoas na sala? {{ sala_com_pessoas }}</p>
    <p>Sala ativa: {{ sala_ativa }}</p>
    <button id="fecharModal" @click="fecharModal">Fechar</button>
  </div>
</template>



<script>
import mqtt from "mqtt";
export default {
  data() {
    let host = "mqtt-dashboard.com";
    let port = 8884;
    let protocol = "wss";

    return {
      sala_luz: null,
      sala_com_pessoas: null,
      sala_ativa: null,
      sala_temp: null,
      numero_sala_clicada: null,

      // Configurações de conexão MQTT
      connection: {
        protocol,
        host,
        port,
        endpoint: "/mqtt",
        clean: true,
        connectTimeout: 30 * 1000, // ms
        reconnectPeriod: 4000, // ms
        clientId:
          "clientId-PCRT0tbu2s" + Math.random().toString(16).substring(2, 8),
        username: "Isaac",
        password: "Isaac",
      },
      // Lista de tópicos de inscrição MQTT
      subscriptions: [
        //{ topic: "ssc/443/acesso", qos: 0 },
        { topic: "ssc/+/status", qos: 0 },
      ],
      // Configurações para publicação MQTT
      publish: {
        topic: "testtopic/1",
        qos: 0,
        payload: '{ "msg": "Hello, I am browser." }',
      },
      // Mensagens recebidas ficam armazenadas em status e acesso. Uma pra cada topico
      status: "",
      acesso: "",
      // Lista de QoS disponíveis
      qosList: [0, 1, 2],
      // Estado da conexão MQTT
      client: {
        connected: false,
      },
      // Indica se a inscrição foi bem-sucedida
      subscribeSuccess: false,
      // Indica se está tentando conectar
      connecting: false,
      // Contador de tentativas de reconexão
      retryTimes: 0,
      modal: false,
    };
  },
  methods: {
    // Método para inicializar os dados do cliente MQTT
    initData() {
      this.client = {
        connected: false,
      };
      this.retryTimes = 0;
      this.connecting = false;
      this.subscribeSuccess = false;
    },
    // Método para lidar com reconexões
    handleOnReConnect() {
      this.retryTimes += 1;
      if (this.retryTimes > 5) {
        try {
          this.client.end();
          this.initData();
          this.$message.error("Connection maxReconnectTimes limit, stop retry");
        } catch (error) {
          this.$message.error(error.toString());
        }
      }
    },
    // Método para criar a conexão MQTT
    createConnection() {
      try {
        this.connecting = true;
        const { protocol, host, port, endpoint, ...options } = this.connection;
        const connectUrl = `${protocol}://${host}:${port}${endpoint}`;
        this.client = mqtt.connect(connectUrl, options);
        if (this.client.on) {
          this.client.on("connect", () => {
            this.connecting = false;
            console.log("Conexão feita com sucesso!");

            this.subscribeToTopics(); //chamando metodo para se inscrever em um topico, no caso dois topicos

            // recebendo as mensagens dos topicos
            this.client.on("message", (topic, message) => {
              let n_sala = topic.split("/")[1];
              // if (topic === "ssc/443/status") {
              this.status = message;
              console.log(this.status);
              console.log(
                `Mensagem Recebida do tópico "ssc/${n_sala}/status": ${message}`
              );
              if (n_sala == 443) n_sala = 10;
              if (message == "true") {
                this.mudar_cor_sala(n_sala, true);
              } else if (message == "false") {
                this.mudar_cor_sala(n_sala, false);
              }
              // } else
              if (topic === "ssc/443/acesso") {
                this.acesso = message;
                console.log(this.acesso);
                console.log(
                  `Mensagem Recebida do tópico "ssc/443/acesso": ${message}`
                );
              }
            });
          });
          this.client.on("reconnect", this.handleOnReConnect);
          this.client.on("error", (error) => {
            console.log("Connection failed", error);
          });
        }
      } catch (error) {
        this.connecting = false;
        console.log("mqtt.connect error", error);
      }
    },
    // Método para se inscrever nos tópicos MQTT
    subscribeToTopics() {
      this.subscriptions.forEach(({ topic, qos }) => {
        this.client.subscribe(topic, { qos }, (error, res) => {
          if (error) {
            console.log("Subscribe to topics error", error);
            return;
          }
          this.subscribeSuccess = true;
          console.log("Subscribe to topics res", res);
        });
      });
    },
    // Método para cancelar a inscrição em um tópico MQTT
    doUnSubscribe() {
      const { topic } = this.subscription;
      this.client.unsubscribe(topic, (error) => {
        if (error) {
          console.log("Unsubscribe error", error);
        }
      });
    },
    // Método para publicar uma mensagem MQTT
    doPublish() {
      const { topic, qos, payload } = this.publish;
      this.client.publish(topic, payload, { qos }, (error) => {
        if (error) {
          console.log("Publish error", error);
        }
      });
    },
    // Método para desconectar o cliente MQTT
    destroyConnection() {
      if (this.client.connected) {
        try {
          this.client.end(false, () => {
            this.initData();
            console.log("Successfully disconnected!");
          });
        } catch (error) {
          console.log("Disconnect failed", error.toString());
        }
      }
    },
    // Método que exibir as informações da sala que o usuário clicou
    exibir_modal(sala_numero) {
      this.modal = true;
      console.log("foi", sala_numero);
      this.numero_sala_clicada = sala_numero;

      this.exibir_dados_sala(10, true, true, true);
    },
    exibir_dados_sala(sala_temp, sala_ativa, sala_com_pessoas, sala_luz) {
      this.sala_temp = sala_temp;
      this.sala_ativa = sala_ativa;
      this.sala_com_pessoas = sala_com_pessoas;
      this.sala_luz = sala_luz;
    },
    fecharModal() {
      this.modal = false;
    },

    // Método que chama o método mudar_cor_sala do compunente Mapa_SGA
    mudar_cor_sala(sala_numero, on_off) {
      this.$emit("mudar_cor_sala", sala_numero, on_off);
    },
  },
  // mounted usado para fazer uma conexão automatica
  mounted() {
    this.createConnection();
  },
};
</script>

<style scoped>
#div-info {
  position: absolute;
  top: 150px;
  left: 10px;
  height: 400px;
  width: 250px;
  background-color: white;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.5);
  border-radius: 8px;
  z-index: 10;
  padding: 10px;
}

#div-info > h2 {
  margin: 15px 5px;
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

#div-info > p {
  margin: 5px 0 10px 20px;
  text-align: left;
  font-size: 14px;
  color: #555;
}

#fecharModal {
  margin-top: 200px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 8px;
  box-shadow: 2px 2px 6px rgba(0, 0, 0, 0.1);
  width: 70px;
  height: 35px;
  font-size: 14px;
  font-weight: bold;
  transition: background-color 0.3s, transform 0.3s;
}

#fecharModal:hover {
  cursor: pointer;
  background-color: #0056b3;
  transform: translateY(-2px);
}

#fecharModal:focus {
  outline: none;
  box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.5);
}

</style>