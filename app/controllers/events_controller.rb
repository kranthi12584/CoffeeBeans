class EventsController < ApplicationController

  def index
  end

  # creates the event and will get the response from API
  def create_event_a
    begin
      @response = create_iterable_request("https://api.iterable.com/api/events/track", request_body, event_response)
      if @response.code == 200
        flash[:notice] = "Event created"
        redirect_to action: "index"
      end
    rescue => e
      flash[:notice] = "#{e}"
      redirect_to action: "index"
    end
  end

  # creates the event & sends email and will get the response from API
  def create_event_b
    begin
      @response = create_iterable_request("https://api.iterable.com/api/events/track", request_body, event_response)
      if @response.code == 200
        @email_response = create_iterable_request("https://api.iterable.com/api/email/target", request_body_for_email, email_response)
        if @email_response.code == 200
          flash[:notice] = "Event created and email sent"
          redirect_to action: "index"
        end
      end
    rescue => e
      flash[:notice] = "#{e}"
      redirect_to action: "index"
    end
  end

  private

  # request body for event creation with uniq event name
  def request_body
    event_name = "Test event #{SecureRandom.base64(10)}"

    return "{
      'email': #{current_user.email},
      'userId': #{current_user.id},
      'eventName': #{event_name},
      'createdAt': #{Time.now},
      'dataFields': {},
      'campaignId': 'Camp123',
      'templateId': 0,
      'createNewFields': 'true'
    }"
  end

  # request body for email sending
  def request_body_for_email
    "{
      'campaignId': 'Camp123',
      'recipientEmail': #{current_user.email},
      'recipientUserId': #{current_user.id},
      'dataFields': {
        'eventCreation': 'true'
      },
      'sendAt': #{Time.now}
    }"
  end

  #event creation response from API
  def event_response
    "{
      'msg': 'event created',
      'code': 'success',
      'params': {}
    }"
  end

  #email response from API
  def email_response
    "{
      'msg': 'event created and email sent',
      'code': 'success',
      'params': {}
    }"
  end

  # Here it stubs the request and raise a request via RestClient
  def create_iterable_request(uri, body, response)
    stub_request(:post, uri).
      with(body: body, headers: { 'Content-Type' => 'application/json',
                                  "Api-Key" => "#{Rails.application.credentials.ITERABLE_API_KEY}" }).
      to_return(status: 200, body: response, headers: {})

    RestClient.post(uri, body,
                    content_type: 'application/json',
                    "Api-Key": "#{Rails.application.credentials.ITERABLE_API_KEY}")
  end
end
