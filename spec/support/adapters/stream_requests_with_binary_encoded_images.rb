require 'spec_helper'

RSpec.shared_examples 'stream requests with binary encoded images' do | options = {} |

  let( :binary_content_of_red_balloon ) {
    build_binary_content( fixture_file_path( 'single-red-balloon.png'  ) )
  }

  let( :binary_content_of_three_balloons ) {
    build_binary_content( fixture_file_path( 'three-balloons.png'  ) )
  }

  context 'where there is a single message and a binary encoded image' do 
    it 'streams the appropriate generated text' do

      conversation = create_conversation( "identify this image; all lower case\n" )
      conversation.messages.last.append_content( binary_content_of_red_balloon )

      text = ''
      response = create_and_make_stream_request( send( options[ :adapter ] || :adapter ), conversation ) do | result | 
        
        expect( result ).to be_a( Intelligence::ChatResult )
        expect( result.choices ).not_to be_nil
        expect( result.choices.length ).to eq( 1 )
        
        choice = result.choices.first
        expect( choice.message ).to be_a( Intelligence::Message )
        expect( choice.message.contents ).not_to be_nil

        text += message_contents_to_text( choice.message )

      end
      
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Intelligence::ChatResult )
      expect( response.result.choices ).not_to be_nil
      expect( response.result.choices.first ).to be_a( Intelligence::ChatResultChoice )
      expect( response.result.choices.first.end_reason ).to eq( options[ :end_reason ] || :ended )

      expect( text ).to match( /balloon/i ), "Expected text to include 'balloon' but got '#{text}'."
    end
  end

  context 'where there are multiple messages with the first including a binary encoded image' do
    it 'streams the appropriate generated text' do

      conversation = create_conversation( "identify this image; all lower case\n" )
      conversation.messages.last.append_content( binary_content_of_red_balloon )
      conversation.messages << build_text_message( :assistant, "balloon\n" )
      conversation.messages << build_text_message( :user, "what color?\nrespond in less than 16 words" )
      
      text = ''
      response = create_and_make_stream_request( send( options[ :adapter ] || :adapter ), conversation ) do | result | 
        
        expect( result ).to be_a( Intelligence::ChatResult )
        expect( result.choices ).not_to be_nil
        expect( result.choices.length ).to eq( 1 )
        
        choice = result.choices.first
        expect( choice.message ).to be_a( Intelligence::Message )
        expect( choice.message.contents ).not_to be_nil

        text += message_contents_to_text( choice.message )

      end
      
      expect( response.success? ).to be( true ), response_error_description( response )
      expect( response.result ).to be_a( Intelligence::ChatResult )
      expect( response.result.choices ).not_to be_nil
      expect( response.result.choices.first ).to be_a( Intelligence::ChatResultChoice )
      expect( response.result.choices.first.end_reason ).to eq( options[ :end_reason ] || :ended )

      expect( text ).to match( /red/i ), "Expected text to include 'red' but got '#{text}'."

    end
  end

  context 'where there are multiple messages with each including a binary encoded image' do
    it 'streams the appropriate generated text' do

      conversation = create_conversation( "identify this image; all lower case\n" )
      conversation.messages.last.append_content( binary_content_of_red_balloon )
      conversation.messages << build_text_message( :assistant, "one red balloon\n" )
      message = build_text_message( :user, "what about this image? respons in less than 16 words\n" )
      message.append_content( binary_content_of_three_balloons )
      conversation.messages << message 
      
      text = ''
      response = create_and_make_stream_request( send( options[ :adapter ] || :adapter ), conversation ) do | result | 
        
        expect( result ).to be_a( Intelligence::ChatResult )
        expect( result.choices ).not_to be_nil
        expect( result.choices.length ).to eq( 1 )
        
        choice = result.choices.first
        expect( choice.message ).to be_a( Intelligence::Message )
        expect( choice.message.contents ).not_to be_nil

        text += message_contents_to_text( choice.message )

      end
      
      expect( response.success? ).to be true
      expect( response.result ).to be_a( Intelligence::ChatResult )
      expect( response.result.choices ).not_to be_nil
      expect( response.result.choices.first ).to be_a( Intelligence::ChatResultChoice )
      expect( response.result.choices.first.end_reason ).to eq( options[ :end_reason ] || :ended )

      expect( text ).to match( /balloons/i ), "Expected text to include 'balloons' but got '#{text}'."
    
    end
  end

end
