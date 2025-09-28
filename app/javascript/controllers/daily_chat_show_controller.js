import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messageInput", "sendButton", "chatMessages"]

  connect() {
    // 最新メッセージまでスクロール（chatMessagesTargetが存在する場合のみ）
    if (this.hasChatMessagesTarget) {
      this.chatMessagesTarget.scrollTop = this.chatMessagesTarget.scrollHeight
    }
    // フォーカスを入力欄に
    if (this.hasMessageInputTarget) {
      this.messageInputTarget.focus()
    }
  }

  sendOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      if (this.messageInputTarget.value.trim()) {
        // フォーム送信を実行
        this.sendButtonTarget.click()
      }
    }
  }
}