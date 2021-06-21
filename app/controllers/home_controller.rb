class HomeController < ApplicationController
  def index
    @users = User.all
  end

  def search
    @first_name = params[:first_name].to_s.strip.downcase
    @last_name = params[:last_name].to_s.strip.downcase
    @url = params[:url].to_s.strip.downcase
  
    # generate_possible_email_combinations
    emails = generate_possible_email_combinations
     p emails
    @found = false
    emails.each do |email|
      p "starting for email #{email}"
      @response = MailboxlayerService.new(email).perform
      p @response
      break if validate_response(@response)
    end

    if !@found
      flash[:alert] = "No valid emails found"
    end
    redirect_to root_path
  end

  private

    def generate_possible_email_combinations
      [
        "#{@first_name}.#{@last_name}@#{@url}",
        "#{@first_name}@#{@url}",
        "#{@first_name}#{@last_name}@#{@url}",
        "#{@last_name}.#{@first_name}@#{@url}",
        "#{@first_name[0]}.#{@last_name}@#{@url}",
        "#{@first_name[0]}#{@last_name[0]}@#{@url}"
      ]
    end

    def validate_response(response)
      if response["format_valid"] == true && response["mx_found"] == true && response["smtp_check"] == true && response["catch_all"].nil?
        p found: "#{response["email"]}"
        if user = User.create(first_name: @first_name, last_name: @last_name, email: response["email"])
          @found = true
          flash[:notice] = "User with email #{user.email} was found and added successfully"
        end
        true
      else
        false
      end
    end
end
