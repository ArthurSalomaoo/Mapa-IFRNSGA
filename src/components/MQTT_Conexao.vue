<template>
  <!-- Parte principal de como funciona as coisas na exibição -->
  <button
    type="success"
    size="small"
    class="conn-btn"
    style="margin-right: 20px"
    :disabled="client.connected"
    @click="createConnection"
    :loading="connecting"
  >
    <!-- mostrando o estado da conexao na tela -->
    <h1 class="Estado-conexão">
      Estado da Conexão: {{ client.connected ? "Conectado" : "Conectar" }}
    </h1>
  </button>

  <!-- exibindo mensagens na tela -->
  <h2>Tópico Status: {{ status }}</h2>
  <h2>Tópico Acesso: {{ acesso }}</h2>
  <h2 @click="mudar_cor_sala">teste</h2>
  <!-- Acima termina como funciona a exibição -->
  <div id="div-info" v-if="div_dados">
    <h2>oi {{numero_sala_clicada}}</h2>
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
      // Configurações de conexão MQTT
      numero_sala_clicada: null,
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
        { topic: "ssc/443/acesso", qos: 0 },
        { topic: "ssc/443/status", qos: 0 },
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
      div_dados: false,
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
              if (topic === "ssc/443/status") {
                this.status = message;
                console.log(this.status);
                console.log(
                  `Mensagem Recebida do tópico "ssc/443/status": ${message}`
                );
                if (message == "true") {
                  this.mudar_cor_sala(10, true);
                } else if(message == "false"){
                  this.mudar_cor_sala(10, false)
                }
              } else if (topic === "ssc/443/acesso") {
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
    exibir_dados(sala_numero) {
      this.div_dados = !this.div_dados;
      console.log("foi", sala_numero);
      this.numero_sala_clicada = sala_numero
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
  margin-top: 20px;
  height: 400px;
  width: 200px;
  background-color: palegoldenrod;
}
</style>